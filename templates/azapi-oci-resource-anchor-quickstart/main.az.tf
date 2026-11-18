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

resource "azapi_resource" "resource_anchor" {
  type      = "Oracle.Database/resourceAnchors@2025-09-01"
  name      = var.resource_anchor_name
  parent_id = local.resource_group_id
  location  = "global"
  tags      = var.tags
  body = {
    properties = {}
  }
}
