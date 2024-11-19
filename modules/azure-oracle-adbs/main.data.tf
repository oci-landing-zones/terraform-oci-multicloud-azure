data "azurerm_virtual_network" "virtual_network" {
  name                = var.nw_vnet_name
  resource_group_name = var.nw_resource_group
}

data "azurerm_subnet" "subnet" {
  name                 = var.nw_delegated_subnet_name
  virtual_network_name = var.nw_vnet_name
  resource_group_name  = var.nw_resource_group
}

data "azurerm_resource_group" "resource_group" {
  name = var.db_resource_group
}
