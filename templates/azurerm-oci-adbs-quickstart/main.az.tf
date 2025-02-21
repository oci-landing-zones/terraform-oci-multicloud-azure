provider "azurerm" {
  features {}
}

locals {
  common_tags = var.common_tags
  az_region   = var.az_region
  adbs_name   = var.random_suffix_length > 0 ? "${var.name}${random_string.suffix[0].result}" : var.name
}

resource "random_string" "suffix" {
  count = var.random_suffix_length > 0 ? 1 : 0

  length  = var.random_suffix_length
  special = false
  upper   = false
  numeric = true
}

# Azure Resource Group
module "azure-resource-grp" {
  source              = "../../modules/azure-resource-grp"
  az_region           = var.az_region
  resource_group_name = var.resource_group
  az_tags             = local.common_tags
  new_rg              = var.new_rg
}

# Azure VNet with delegated subnet
module "avm_network" {
  count = var.new_vnet ==  true ? 1 : 0

  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  # depends_on = [ module.azure-resource-grp ]

  tags                = local.common_tags
  resource_group_name = module.azure-resource-grp.resource_group_name
  location            = var.az_region
  name                = var.virtual_network_name
  address_space       = [var.virtual_network_address_space]

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

data "azurerm_subnet" "delegated_subnet" {
  depends_on = [module.avm_network]

  name                 = var.delegated_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = module.azure-resource-grp.resource_group_name
}

data "azurerm_virtual_network" "this" {
  depends_on = [module.avm_network]

  name                = var.virtual_network_name
  resource_group_name = module.azure-resource-grp.resource_group_name
}

# Oracle Autonomous Database@Azure (Read-only after creation)
module "azurerm_ora_adbs" {
  depends_on = [ module.azure-resource-grp ]
  source                           = "../../modules/azurerm-ora-adbs"
  name                             = local.adbs_name
  resource_group_name              = module.azure-resource-grp.resource_group_name
  location                         = var.az_region
  subnet_id                        = data.azurerm_subnet.delegated_subnet.id
  display_name                     = var.display_name == "" ? local.adbs_name : var.display_name
  db_workload                      = var.db_workload
  mtls_connection_required         = var.mtls_connection_required
  backup_retention_period_in_days  = var.backup_retention_period_in_days
  compute_model                    = var.compute_model
  data_storage_size_in_tbs         = var.data_storage_size_in_tbs
  auto_scaling_for_storage_enabled = var.auto_scaling_for_storage_enabled
  virtual_network_id               = data.azurerm_virtual_network.this.id
  admin_password                   = var.admin_password
  auto_scaling_enabled             = var.auto_scaling_enabled
  character_set                    = var.character_set
  compute_count                    = var.compute_count
  national_character_set           = var.national_character_set
  license_model                    = var.license_model
  db_version                       = var.db_version
  customer_contacts                = var.customer_contacts
  tags                             = local.common_tags
}