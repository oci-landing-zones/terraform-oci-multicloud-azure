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
  azure_to_oci_ad_internal_mappping = tomap({
    "East US"= {
      "zone_mapping" = {"eastus-az1" = "iad-ad-1",
        "eastus-az3" = "iad-ad-3",}
      "region" = "Ashburn"

    }
    "Germany West Central" = {
      "zone_mapping" = {"germanywestcentral-az2" = "eu-frankfurt-1-ad-1",
        "germanywestcentral-az3" = "eu-frankfurt-1-ad-3",}
      "region" = "Frankfurt"

    }
    "UK South" = {
      "zone_mapping" = {"uksouth-az1" = "uk-london-1-ad-2",
        "uksouth-az2" = "uk-london-1-ad-1",}
      "region" = "London"

    }
    "West US" = {
      "zone_mapping" = {"West US"="us-sanjose-1-ad-1",}
      "region" = "San Jose"

    }
    "France Central" ={
      "zone_mapping" = {"francecentral-az2" = "eu-paris-1-ad-1",
        "francecentral-az3" = "eu-paris-1-ad-1",}
      "region" = "Paris"

    }
    "Canada Central" = {
      "zone_mapping" = {"canadacentral-az2" = "ca-toronto-1-ad-1",
        "canadacentral-az3" = "ca-toronto-1-ad-1",}
      "region" = "Toronto"

    }
    "Australia East" = {
      "zone_mapping" = {"australiaeast-az2" = "ap-sydney-1-ad-1",
        "australiaeast-az3" = "ap-sydney-1-ad-1",}
      "region" = "Sydney"

    }
    "Italy North"={
      "zone_mapping" = {"italynorth-az1" = "eu-milan-1-ad-1",
        "italynorth-az2" = "eu-milan-1-ad-1"}
      "region" = "Milan"

    }
  })
  az_physical_zone = length(local.zone_mapping)>0? one(local.zone_mapping).physical_zone : data.azurerm_location.azure_location_info.display_name
  location_info = try(local.azure_to_oci_ad_internal_mappping[data.azurerm_location.azure_location_info.display_name], {})
  location_zone_mapping = try(local.location_info.zone_mapping, {})
  oci_ad = lookup(local.location_zone_mapping, local.az_physical_zone, "None")
  region = lookup(local.location_info, "region", "None")
}

