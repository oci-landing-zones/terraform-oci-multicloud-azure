terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# uncomment for local module run
# provider "azurerm" {
#   features {}
# }

# provider "azapi" {}


data "azurerm_virtual_network" "virtual_network" {
  name                = var.nw_vnet_name
  resource_group_name = var.nw_resource_group
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "subnet" {
  name                 = var.nw_delegated_subnet_name
  virtual_network_name = var.nw_vnet_name
  resource_group_name  = var.nw_resource_group
}


## DB resources 
data "azurerm_resource_group" "resource_group" {
  name = var.db_resource_group
}


resource "azapi_resource" "autonomous_db" {
  type                      = "Oracle.Database/autonomousDatabases@2023-09-01"
  parent_id                 = data.azurerm_resource_group.resource_group.id
  name                      = var.db_name
  schema_validation_enabled = false

  timeouts {
    create = "3h"
    update = "2h"
    delete = "1h"
  }

  body = jsonencode({
    "location" : var.location,
    "properties" : {
      "displayName" : var.db_name,
      "computeCount" : var.db_ecpu_count,
      "dataStorageSizeInGbs" : var.db_storage_in_gb,
      "adminPassword" : var.db_admin_password,
      "dbVersion" : var.db_version,
      "licenseModel" : var.db_license_model,
      "dataBaseType" : var.db_type,
      "computeModel" : var.db_compute_model,
      "dbWorkload" : var.db_workload,
      "permissionLevel" : var.db_permission_level,

      "characterSet" : var.db_character_set,
      "ncharacterSet" : var.db_n_character_set,

      "isAutoScalingEnabled" : var.db_auto_scale_enabled,
      "isAutoScalingForStorageEnabled" : var.db_storage_auto_scale_enabled,

      "vnetId" : data.azurerm_virtual_network.virtual_network.id
      "subnetId" : data.azurerm_subnet.subnet.id
    }
  })
  response_export_values = ["id", "properties.ocid", "properties"]
}

