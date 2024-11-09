terraform {
  required_version = ">=1.2.9"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
    # https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md#3990-april-11-2024
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
    # https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformspecifyingversions.htm#terraformspecifyingversions_ociprovider
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}
