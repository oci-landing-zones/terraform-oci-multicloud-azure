terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_virtual_network" "virtual-network" {
  address_space       = [var.virtual_network_address_space]
  location            = var.location
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "delegated-subnet" {
  address_prefixes     = [var.delegated_subnet_address_prefix]
  name                 = var.delegated_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name

  delegation {
    name = "Oracle.Database/networkAttachments"
    service_delegation {
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Oracle.Database/networkAttachments"
    }
  }
}