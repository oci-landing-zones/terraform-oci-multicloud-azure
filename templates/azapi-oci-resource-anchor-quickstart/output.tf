output "resource_anchor_id" {
  description = "Resource Anchor Azure ARM ID for the Network Anchor quickstart's existing_resource_anchor_id input."
  value       = module.resource_anchor.id
}

output "resource_group_id" {
  description = "Created or reused Azure resource group ARM ID."
  value       = local.resource_group_id
}
