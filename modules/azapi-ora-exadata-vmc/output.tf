output "id" {
  description = "Cloud VM cluster ARM ID."
  value       = azapi_resource.this.id
}
output "ocid" {
  description = "Cloud VM cluster OCI OCID."
  value       = azapi_resource.this.output.properties.ocid
}
output "db_server_ocids" {
  description = "Selected OCI DB server IDs; pin before changing server inventory."
  value       = local.selected_db_servers
}
output "infrastructure_ocid" {
  description = "Selected Exadata infrastructure OCI OCID."
  value       = data.azapi_resource.infrastructure.output.properties.ocid
}
output "resource_anchor_id" {
  description = "Selected Resource Anchor ARM ID."
  value       = var.resource_anchor_id
}
output "network_anchor_id" {
  description = "Selected Network Anchor ARM ID."
  value       = var.network_anchor_id
}
