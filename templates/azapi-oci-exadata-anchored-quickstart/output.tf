output "resource_group_id" {
  description = "Created or reused workload resource group ARM ID."
  value       = local.resource_group_id
}
output "resource_anchor_id" {
  description = "Created or discovered Resource Anchor ARM ID."
  value       = local.resource_anchor_id
}
output "network_anchor_id" {
  description = "Created or discovered Network Anchor ARM ID."
  value       = local.network_anchor_id
}
output "virtual_network_id" {
  description = "Created or discovered VNet ARM ID."
  value       = local.vnet_id
}
output "subnet_id" {
  description = "Created or discovered Oracle delegated subnet ARM ID."
  value       = local.subnet_id
}
output "cloud_exadata_infrastructure_id" {
  description = "New Exadata infrastructure ARM ID."
  value       = module.infrastructure.id
}
output "cloud_exadata_infrastructure_ocid" {
  description = "New Exadata infrastructure OCI OCID."
  value       = module.infrastructure.ocid
}
output "vm_cluster_id" {
  description = "New VM cluster ARM ID."
  value       = module.vm_cluster.id
}
output "vm_cluster_ocid" {
  description = "New VM cluster OCI OCID for later database provisioning."
  value       = module.vm_cluster.ocid
}
output "db_server_ocids" {
  description = "Selected OCI DB server OCIDs. Pin them in db_servers before any infrastructure edit, including tags."
  value       = module.vm_cluster.db_server_ocids
}
