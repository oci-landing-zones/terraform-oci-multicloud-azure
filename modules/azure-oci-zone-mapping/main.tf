terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


## uncomment for local module run
# provider "azurerm" {
#   features {}
# }

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/location
data "azurerm_location" "azure_location_info" {
  location = var.location
}

locals {
  zone_mapping = [for zone_mapping in data.azurerm_location.azure_location_info.zone_mappings : zone_mapping
    if zone_mapping.logical_zone == var.zone
  ]
  azure_to_oci_ad_internal_mappping = jsondecode(file("${path.module}/azure-to-oci-ad-internal-mapping.json"))
  az_physical_zone                  = length(local.zone_mapping) > 0 ? one(local.zone_mapping).physical_zone : data.azurerm_location.azure_location_info.display_name
  location_info                     = try(local.azure_to_oci_ad_internal_mappping[data.azurerm_location.azure_location_info.display_name], {})
  location_zone_mapping             = try(local.location_info.zone_mapping, {})
  oci_ad                            = lookup(local.location_zone_mapping, local.az_physical_zone, "None")
  region                            = lookup(local.location_info, "region", "None")
}

