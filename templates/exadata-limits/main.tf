locals {

  full_zone_mappings = flatten(distinct(
    [for m in values(module.zone_mappings) : m.location_zone_mapping]
  ))
  region = join("", distinct([for z in module.zone_mappings : z.region]))
  template = templatefile("${path.module}/templates/limits_raise_template.tftpl", {
    zone_mapping      = module.zone_mappings
    full_zone_mapping = local.full_zone_mappings
    region            = local.region
    output_zones      = var.zones
    az_far_child_site = var.az_far_child_site
  })
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