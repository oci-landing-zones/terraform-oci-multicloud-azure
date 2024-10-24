# Azure resource group
#   - Create resource group with random suffix if new_rg is true, else
#   - Lookup for resource group ID with the given name
locals {
    resource_group_name = var.new_rg == true ? module.naming.resource_group.name_unique : var.resource_group_name
}

# Align with Azure naming standard
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix = [var.resource_group_name]
}

resource "azurerm_resource_group" "this" {
  count = var.new_rg == true ? 1 :0
  location = var.az_region
  name     = local.resource_group_name
  tags     = var.az_tags
}

data "azurerm_resource_group" "this" {
    name = local.resource_group_name
    depends_on = [ azurerm_resource_group.this ]
}
