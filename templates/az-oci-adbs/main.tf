resource "azurerm_resource_group" "resource_group" {
  location = var.location
  name     = var.resource_group
}

module "adbs_network" {
  source = "../../modules/azure-vnet-subnet"
  providers = {
    azurerm = azurerm
  }
  location                        = var.location
  resource_group_name             = azurerm_resource_group.resource_group.name
  virtual_network_name            = var.virtual_network_name
  delegated_subnet_address_prefix = var.delegated_subnet_address_prefix
  virtual_network_address_space   = var.virtual_network_address_space
  delegated_subnet_name           = var.delegated_subnet_name
}

module "odbas_database" {
  source = "../../modules/azure-oracle-adbs"
  providers = {
    azapi   = azapi
    azurerm = azurerm
  }
  depends_on = [module.adbs_network]

  location                      = var.location
  nw_resource_group             = var.resource_group
  nw_vnet_name                  = var.virtual_network_name
  nw_delegated_subnet_name      = var.delegated_subnet_name
  db_resource_group             = var.resource_group
  db_name                       = var.db_name
  db_admin_password             = var.db_admin_password
  db_compute_model              = var.db_compute_model
  db_ecpu_count                 = var.db_ecpu_count
  db_storage_in_gb              = var.db_storage_in_gb
  db_version                    = var.db_version
  db_license_model              = var.db_license_model
  db_workload                   = var.db_workload
  db_auto_scale_enabled         = var.db_auto_scale_enabled
  db_storage_auto_scale_enabled = var.db_storage_auto_scale_enabled
  db_permission_level           = var.db_permission_level
  db_type                       = var.db_type
  db_character_set              = var.db_character_set
  db_n_character_set            = var.db_n_character_set
} 