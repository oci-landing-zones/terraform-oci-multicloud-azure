locals {
  resource_group_id   = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  subnet_id           = var.create_network ? azurerm_subnet.oracle[0].id : var.existing_subnet_id
  resource_anchor_id  = var.existing_resource_anchor_id == null ? module.resource_anchor[0].id : var.existing_resource_anchor_id
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  count               = var.create_network ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "oracle" {
  count                = var.create_network ? 1 : 0
  name                 = var.delegated_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.delegated_subnet_address_prefix]

  delegation {
    name = "oracle-database"
    service_delegation {
      name = "Oracle.Database/networkAttachments"
      # Azure returns both actions for this delegation; keep them explicit.
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

module "resource_anchor" {
  count             = var.existing_resource_anchor_id == null ? 1 : 0
  source            = "../../modules/azapi-ora-resource-anchor"
  resource_group_id = local.resource_group_id
  name              = var.resource_anchor_name
  tags              = var.tags
}

module "network_anchor" {
  source                = "../../modules/azapi-ora-network-anchor"
  resource_group_id     = local.resource_group_id
  resource_anchor_id    = local.resource_anchor_id
  subnet_id             = local.subnet_id
  name                  = var.network_anchor_name
  location              = var.location
  availability_zone     = var.availability_zone
  oci_vcn_dns_label     = var.oci_vcn_dns_label
  oci_backup_cidr_block = var.oci_backup_cidr_block
  dns                   = var.dns
  tags                  = var.tags
}
