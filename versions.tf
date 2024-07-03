terraform {
  required_version = ">=1.2.9"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    # https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformspecifyingversions.htm#terraformspecifyingversions_ociprovider
    oci = {
      source  = "hashicorp/oci"
      version = ">= 5.0.0"
    }
  }
}
