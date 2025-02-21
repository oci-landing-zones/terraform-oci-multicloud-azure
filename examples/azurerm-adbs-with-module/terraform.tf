terraform {
  # Azure Verified Modules require TF 1.9.2
  required_version = "~> 1.9.2"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.18.0"
    }
  }
}
