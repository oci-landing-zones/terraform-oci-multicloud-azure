locals {
  az_region           = var.az_region
  adbs_name           = "${var.name}${random_string.suffix.result}"
  resource_group_name = module.azure-resource-grp.resource_group_name
}

resource "random_string" "suffix" {
  length  = var.random_suffix_length
  special = false
  upper   = false
  numeric = true
}

# Azure Resource Group
module "azure-resource-grp" {
  source              = "../../modules/azure-resource-grp"
  az_region           = local.az_region
  resource_group_name = var.resource_group
  az_tags             = var.tags
  new_rg              = var.new_rg
}

# Azure VNet
module "avm_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.2.4"

  tags                = var.tags
  resource_group_name = local.resource_group_name
  location            = local.az_region

  name          = var.virtual_network_name
  address_space = [var.virtual_network_address_space]

  subnets = {
    delegated = {
      name             = var.delegated_subnet_name
      address_prefixes = [var.delegated_subnet_address_prefix]

      delegation = [{
        name = "Oracle.Database/networkAttachments"
        service_delegation = {
          name    = "Oracle.Database/networkAttachments"
          actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]

        }
      }]
    }
  }
}

module "azure-oracle-adbs" {
  source = "../../modules/azure-oracle-adbs"
  providers = {
    azapi   = azapi
    azurerm = azurerm
  }
  depends_on = [module.avm_network]

  tags     = var.tags
  location = local.az_region

  nw_resource_group        = local.resource_group_name
  nw_vnet_name             = var.virtual_network_name
  nw_delegated_subnet_name = var.delegated_subnet_name

  db_resource_group                           = local.resource_group_name
  name                                        = local.adbs_name
  display_name                                = var.display_name == null ? local.adbs_name : var.display_name
  compute_count                               = var.compute_count
  data_storage_size_in_tbs                    = var.data_storage_size_in_tbs
  admin_password                              = var.admin_password
  db_version                                  = var.db_version
  license_model                               = var.license_model
  compute_model                               = var.compute_model
  db_workload                                 = var.db_workload
  permission_level                            = var.permission_level
  character_set                               = var.character_set
  national_character_set                      = var.national_character_set
  auto_scaling_enabled                        = var.auto_scaling_enabled
  auto_scaling_for_storage_enabled            = var.auto_scaling_for_storage_enabled
  backup_retention_period_in_days             = var.backup_retention_period_in_days
  open_mode                                   = var.open_mode
  # cpu_core_count                              = var.cpu_core_count
  local_dataguard_enabled                     = var.local_dataguard_enabled
  local_adg_auto_failover_max_data_loss_limit = var.local_adg_auto_failover_max_data_loss_limit
} 