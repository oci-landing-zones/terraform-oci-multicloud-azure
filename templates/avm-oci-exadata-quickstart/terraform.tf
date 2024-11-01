terraform {
  # Azure Verified Modules require TF 1.9.2
  required_version = "~> 1.9.2"
  required_providers {
    # https://registry.terraform.io/providers/Azure/azapi/latest/docs
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74"
    }
    # https://registry.terraform.io/providers/hashicorp/local/latest/docs
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    # https://registry.terraform.io/providers/hashicorp/random/latest/docs
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    # https://registry.terraform.io/providers/hashicorp/tls/latest/docs
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    # https://registry.terraform.io/providers/oracle/oci/latest/docs
    oci = {
      source  = "oracle/oci"
      version = ">= 6.15.0"
    }
  }
}