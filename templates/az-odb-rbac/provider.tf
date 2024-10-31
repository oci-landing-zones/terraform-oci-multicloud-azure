terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
  }
}

provider "azuread" {
  alias = "az-ad"
}


provider "azurerm" {
  alias = "az-rm"
  features {}
}