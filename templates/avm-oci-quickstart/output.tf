output "exadata_infra" {
  description = "Resource object of Exadata Infrastructure from Azure"
  value = module.avm_exadata_infra.resource
}

output "vm_cluster" {
  description = "Resource object of VM Cluster from Azure"
  value = module.avm_exadata_vmc.resource
}

output "vm_cluster_id" {
  description = "OCID of VM Cluster from Azure for OCI"
  value = module.avm_exadata_vmc.vm_cluster_ocid
}

output "db_home_id" {
  description = "OCID of Oracle Database Home from OCI"
  value = module.oci-database-db-home.db_home_id
}
