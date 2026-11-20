output "id" {
  description = "Exadata infrastructure ARM ID; preserves the provisioning dependency for downstream modules."
  value       = azapi_resource.this.id
}
output "ocid" {
  description = "Exadata infrastructure OCI OCID."
  value       = azapi_resource.this.output.properties.ocid
}
