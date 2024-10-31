# https://github.com/hashicorp/terraform-provider-azurerm/releases
terraform {
  required_providers {
    azapi = {
      source  = "hashicorp/azurerm"
      version = ">=4.7.0"
    }
  }
}

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

resource "azurerm_oracle_autonomous_database" "odaaz_adb" {
  name                             = "example"
  resource_group_name              = "example"
  location                         = "West Europe"
  subnet_id                        = "example"
  display_name                     = "example"
  db_workload                      = "example"
  mtls_connection_required         = false
  backup_retention_period_in_days  = 42
  compute_model                    = "example"
  data_storage_size_in_gbs         = 42
  auto_scaling_for_storage_enabled = false
  virtual_network_id               = "example"
  admin_password                   = "example"
  auto_scaling_enabled             = "example"
  character_set                    = "example"
  compute_count                    = 1.23456
  national_character_set           = "example"
  license_model                    = false
  db_version                       = "example"
}