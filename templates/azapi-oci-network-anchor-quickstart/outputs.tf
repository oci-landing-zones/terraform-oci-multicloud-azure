output "network_anchor_id" {
  description = "Network Anchor ARM ID for the networkAnchorId property of a supported downstream Oracle.Database resource."
  value       = azapi_resource.network_anchor.id
}

output "resource_anchor_id" {
  description = "Created or reused Resource Anchor ARM ID."
  value       = local.resource_anchor_id
}

output "subnet_id" {
  description = "Created or reused delegated subnet ARM ID."
  value       = local.subnet_id
}

output "resource_group_id" {
  description = "Created or reused Azure resource group ARM ID."
  value       = local.resource_group_id
}
