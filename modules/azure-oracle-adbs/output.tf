output "autonomous_db_id" {
  value = jsondecode(azapi_resource.autonomous_db.output).id
}

output "autonomous_db_ocid" {
  value = jsondecode(azapi_resource.autonomous_db.output).properties.ocid
}

output "autonomous_db_properties" {
  value = jsondecode(azapi_resource.autonomous_db.output).properties
}
