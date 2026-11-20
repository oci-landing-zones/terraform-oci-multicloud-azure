output "id" {
  description = "Network Anchor ARM ID."
  value       = azapi_resource.this.id
}
output "resource_anchor_id" {
  description = "Selected Resource Anchor ARM ID."
  value       = var.resource_anchor_id
}
output "subnet_id" {
  description = "Selected delegated subnet ARM ID."
  value       = var.subnet_id
}
