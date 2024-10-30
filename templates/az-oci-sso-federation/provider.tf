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
    # https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformspecifyingversions.htm#terraformspecifyingversions_ociprovider
    oci = {
      source  = "hashicorp/oci"
      version = ">= 5.0.0"
    }
  }
}



provider "oci" {
  alias               = "oci-st"
  auth                = "SecurityToken"
  config_file_profile = var.config_file_profile
  region              = var.region
}

provider "oci" {
  alias  = "oci-ip"
  auth   = "InstancePrincipal"
  region = var.region
}


provider "azuread" {
  alias = "az-ad"
}


provider "azurerm" {
  alias = "az-rm"
  features {}
}
