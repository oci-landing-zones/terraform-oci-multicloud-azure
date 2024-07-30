output "location_zone_mapping" {
  value = data.azurerm_location.azure_location_info.zone_mappings
}

output "internal_ad" {
  value = local.oci_ad
}

output "az_physical_zone" {
  value = local.az_physical_zone
}

output "region" {
  value = local.region
}

output "logical_zone" {
  value = var.zone
}