# https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }
}

locals {
  address_space = var.address_space != null ? var.address_space : [var.virtual_network_address_space]
  subnets = var.subnets != null ? var.subnets : {
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

module "vnet_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  address_space       = local.address_space
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  subnets             = local.subnets
  tags                = var.tags
}
