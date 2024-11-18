output "autonomous_db_id" {
  value = azapi_resource.autonomous_db.output.id
}

output "autonomous_db_ocid" {
  value = azapi_resource.autonomous_db.output.properties.ocid
}

output "autonomous_db_properties" {
  value = azapi_resource.autonomous_db.output.properties
}
