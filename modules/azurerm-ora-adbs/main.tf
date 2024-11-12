terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.9.0"
    }
  }
}

resource "azurerm_oracle_autonomous_database" "this" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  subnet_id                        = var.subnet_id
  display_name                     = var.display_name
  db_workload                      = var.db_workload
  mtls_connection_required         = var.mtls_connection_required
  backup_retention_period_in_days  = var.backup_retention_period_in_days
  compute_model                    = var.compute_model
  data_storage_size_in_tbs         = var.data_storage_size_in_tbs
  auto_scaling_for_storage_enabled = var.auto_scaling_for_storage_enabled
  virtual_network_id               = var.virtual_network_id
  admin_password                   = var.admin_password
  auto_scaling_enabled             = var.auto_scaling_enabled
  character_set                    = var.character_set
  compute_count                    = var.compute_count
  national_character_set           = var.national_character_set
  license_model                    = var.license_model
  db_version                       = var.db_version
  customer_contacts                = var.customer_contacts
  tags                             = var.tags
  lifecycle {
    ignore_changes = [ 
      name,
      display_name,
      db_workload,
      mtls_connection_required,
      backup_retention_period_in_days,
      compute_model,                    
      data_storage_size_in_tbs,         
      auto_scaling_for_storage_enabled,
      admin_password,
      auto_scaling_enabled,            
      character_set,
      # compute_count,
      national_character_set,
      license_model,
      db_version,                       
      customer_contacts 
    ]
  }
}

data "azurerm_oracle_autonomous_database" "this" {
  depends_on = [ azurerm_oracle_autonomous_database.this ]
  name                = azurerm_oracle_autonomous_database.this.name
  resource_group_name = azurerm_oracle_autonomous_database.this.resource_group_name
}