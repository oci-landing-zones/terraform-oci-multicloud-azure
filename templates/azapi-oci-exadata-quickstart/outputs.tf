output "cloud_exadata_infrastructure_id" {
  description = "Created or reused Exadata infrastructure Azure ARM ID."
  value       = local.infrastructure_id
}

output "cloud_exadata_infrastructure_ocid" {
  description = "Exadata infrastructure OCI OCID returned by the API."
  value       = var.existing_cloud_exadata_infrastructure_id == null ? azapi_resource.infrastructure[0].output.properties.ocid : data.azapi_resource.infrastructure[0].output.properties.ocid
}

output "vm_cluster_id" {
  description = "Cloud VM cluster Azure ARM ID."
  value       = azapi_resource.vm_cluster.id
}

output "vm_cluster_ocid" {
  description = "Cloud VM cluster OCI OCID for subsequent OCI database provisioning."
  value       = azapi_resource.vm_cluster.output.properties.ocid
}

output "resource_group_id" {
  description = "Created or reused workload resource group ARM ID."
  value       = local.resource_group_id
}

output "db_server_ocids" {
  description = "OCI DB server OCIDs selected for this VM cluster. Pin these in db_servers before expanding infrastructure when using automatic selection."
  value       = local.selected_db_servers
}

output "resource_anchor_id" {
  description = "Existing Resource Anchor ARM ID used by the Exadata infrastructure and VM cluster."
  value       = var.resource_anchor_id
}

output "network_anchor_id" {
  description = "Existing Network Anchor ARM ID used by the VM cluster."
  value       = var.network_anchor_id
}
