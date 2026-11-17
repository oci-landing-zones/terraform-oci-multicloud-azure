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
