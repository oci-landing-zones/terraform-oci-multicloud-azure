locals {
  resource_group_id = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
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

module "resource_anchor" {
  source            = "../../modules/azapi-ora-resource-anchor"
  resource_group_id = local.resource_group_id
  name              = var.resource_anchor_name
  tags              = var.tags
}
