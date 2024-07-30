locals {

  output_zones     = length(local.zone_mappings) == 0 ? "N/A" : var.zones
  zone_mappings    = join("\n", distinct(flatten([
    for k in flatten([for z in module.zone_mappings : z.location_zone_mapping]) :
    "\nlogical_zone: ${k.logical_zone}, physical_zone: ${k.physical_zone}"
  ])))
  shape_per_zone = join("\n", flatten([for z in module.zone_mappings : "AZ logical Zone: ${z.logical_zone} AZ Pyhsical Zone: ${z.az_physical_zone} Internal AD: ${z.internal_ad}:\n${local.shape_info}\n"]))
  region = join("", distinct([for z in module.zone_mappings : z.region]))
  description_info = "We need to provision a new Prod Exadata Cloud Infrastructure.\n${local.customer_info}\n${local.region_info}\nTenancy OCID: <Put user's Tenancy OCID Here>\n"
  customer_info = "Customer Name: <Put Customer Name Here>\n4 Letter Customer ID: <Customer ID or N/A>\nTenancy Name: <Put user's Tenancy Name Here>\nCompartment: <Customer compartment OCID>"
  shape_info = "\tShape: Exadata X9M (Exadata X9M-2) of <number> Compute nodes and <number> Storage nodes\n"
  region_info = "Region: ${local.region}\n    ${indent(4,local.shape_per_zone)}\nAzure Far Child Site: ${var.az_far_child_site}\n\nAzure logic zones: ${local.output_zones}\n\nAzure availibility zone mapping: {\n${indent(2,local.zone_mappings)}\n}"
}

module "zone_mappings" {
  source = "../../modules/azure-oci-zone-mapping"
  providers = {
    azurerm = azurerm
  }
  for_each = toset(split(",", var.zones))
  zone     = each.value
  location = var.location
}