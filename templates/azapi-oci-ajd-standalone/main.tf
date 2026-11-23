# Standalone Oracle Autonomous JSON Database (AJD) workaround for AzureRM #33792.
# Share this file alone; it has no module or repository dependencies.
# Requires an onboarded Oracle Database@Azure subscription and permission to
# create resource groups, delegated networking, and Oracle databases.
# Register Oracle.Database and Microsoft.Network before deployment.
#
# Usage:
#   az login --tenant <azure-tenant-id>
#   az account set --subscription <azure-subscription-id>
#   terraform init
#   terraform plan -out=ajd.tfplan
#   terraform apply ajd.tfplan
# Supply subscription_id/location through a local tfvars file or TF_VAR_*.
# Supply TF_VAR_admin_password through protected terminal/pipeline inputs.
# Plans and state contain credentials: retain them privately; never publish them.
# Applying provisions paid database capacity. Review sizing and licensing first.

terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azapi" {
  subscription_id            = var.subscription_id
  skip_provider_registration = true
}

provider "azurerm" {
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  features {}
}

variable "subscription_id" {
  description = "Onboarded Azure subscription ID; its service linkage selects the OCI tenancy."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "location" {
  description = "Azure region supporting Oracle Autonomous Database in this subscription."
  type        = string
  nullable    = false
}

variable "name_prefix" {
  description = "Unique database name and prefix for the new group and networking; 1-14 letters/numbers, starting with a letter."
  type        = string
  default     = "oradbajd"
  nullable    = false
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9]{0,13}$", var.name_prefix))
    error_message = "name_prefix must contain 1-14 letters/numbers and start with a letter."
  }
}

variable "admin_password" {
  description = "ADMIN password. Supply through protected inputs; never embed it in this shareable file."
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition = (
      length(var.admin_password) >= 12 && length(var.admin_password) <= 30 &&
      can(regex("[A-Z]", var.admin_password)) &&
      can(regex("[a-z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password)) &&
      !strcontains(lower(var.admin_password), "admin") &&
      !strcontains(var.admin_password, "\"")
    )
    error_message = "Use 12-30 characters including uppercase, lowercase and a digit, without double quotes or 'admin'."
  }
}

variable "db_version" {
  description = "An AJD database version available in the target region; verify the service version metadata."
  type        = string
  default     = "23ai"
  nullable    = false
}

variable "compute_count" {
  description = "ECPUs allocated to this paid database."
  type        = number
  default     = 2
  nullable    = false
  validation {
    condition     = var.compute_count >= 2 && floor(var.compute_count) == var.compute_count
    error_message = "compute_count must be an integer of at least 2 ECPUs."
  }
}

variable "data_storage_size_in_tbs" {
  description = "Allocated database storage in TB; confirm service limits and pricing before applying."
  type        = number
  default     = 1
  nullable    = false
  validation {
    condition     = var.data_storage_size_in_tbs >= 1 && floor(var.data_storage_size_in_tbs) == var.data_storage_size_in_tbs
    error_message = "data_storage_size_in_tbs must be a positive integer."
  }
}

variable "license_model" {
  description = "AJD requires LicenseIncluded; BringYourOwnLicense is not supported."
  type        = string
  default     = "LicenseIncluded"
  nullable    = false
  validation {
    condition     = var.license_model == "LicenseIncluded"
    error_message = "Autonomous JSON Database requires license_model = LicenseIncluded. BringYourOwnLicense is not supported."
  }
}

variable "vnet_address_space" {
  description = "Private IPv4 VNet range; avoid overlap with connected networks."
  type        = string
  default     = "10.50.0.0/16"
  nullable    = false
  validation {
    condition     = can(cidrnetmask(var.vnet_address_space))
    error_message = "vnet_address_space must be an IPv4 CIDR."
  }
}

variable "subnet_address_prefix" {
  description = "Oracle-delegated subnet range inside the VNet."
  type        = string
  default     = "10.50.1.0/24"
  nullable    = false
  validation {
    condition     = can(cidrnetmask(var.subnet_address_prefix))
    error_message = "subnet_address_prefix must be an IPv4 CIDR."
  }
}

variable "tags" {
  description = "Tags for the new resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.name_prefix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "oracle" {
  name                 = "snet-${var.name_prefix}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_address_prefix]
  delegation {
    name = "oracle-database"
    service_delegation {
      name = "Oracle.Database/networkAttachments"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azapi_resource" "ajd" {
  type      = "Oracle.Database/autonomousDatabases@2025-09-01"
  name      = var.name_prefix
  parent_id = azurerm_resource_group.this.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      dataBaseType                   = "Regular"
      dbWorkload                     = "AJD"
      displayName                    = var.name_prefix
      adminPassword                  = var.admin_password
      dbVersion                      = var.db_version
      computeModel                   = "ECPU"
      computeCount                   = var.compute_count
      dataStorageSizeInTbs           = var.data_storage_size_in_tbs
      licenseModel                   = var.license_model
      isAutoScalingEnabled           = false
      isAutoScalingForStorageEnabled = false
      isMtlsConnectionRequired       = true
      vnetId                         = azurerm_virtual_network.this.id
      subnetId                       = azurerm_subnet.oracle.id
    }
  }
  response_export_values = ["properties.ocid", "properties.lifecycleState"]
  timeouts {
    create = "3h"
    update = "2h"
    delete = "1h"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "autonomous_database_id" {
  value = azapi_resource.ajd.id
}

output "autonomous_database_ocid" {
  value = azapi_resource.ajd.output.properties.ocid
}

output "lifecycle_state" {
  value = azapi_resource.ajd.output.properties.lifecycleState
}
