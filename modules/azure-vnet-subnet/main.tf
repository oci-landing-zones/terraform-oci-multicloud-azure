terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_virtual_network" "virtual-network" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.virtual_network_name
  address_space       = [var.virtual_network_address_space]
}

resource "azurerm_subnet" "delegated-subnet" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  name                 = var.delegated_subnet_name
  address_prefixes     = [var.delegated_subnet_address_prefix]

  delegation {
    name = "Oracle.Database/networkAttachments"
    service_delegation {
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Oracle.Database/networkAttachments"
    }
  }
}