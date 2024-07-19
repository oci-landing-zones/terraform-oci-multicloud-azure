terraform {
  backend "local" {}

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.99.0"
    }
    # https://registry.terraform.io/providers/Azure/azapi/latest/docs
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
}


provider "azurerm" {
  features {}
}