terraform {
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
    # https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformspecifyingversions.htm#terraformspecifyingversions_ociprovider
    oci = {
      source  = "hashicorp/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "azurerm" {
  features {
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

provider "azapi" {}
