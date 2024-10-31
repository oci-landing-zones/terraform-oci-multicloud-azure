terraform {
  backend "local" {}

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}