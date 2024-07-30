output "description" {
  value = local.description_info
#  value = "regionName: ${var.location}\nAzure Logical Zone: ${local.output_zones}\nZone Mapping: {\n${local.zone_mappings}\n}"
}
