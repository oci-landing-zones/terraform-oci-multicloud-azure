data "oci_database_database" "this" {
  provider    = oci.resource
  database_id = var.database_id
}

data "oci_database_cloud_vm_cluster" "this" {
  provider            = oci.resource
  cloud_vm_cluster_id = data.oci_database_database.this.vm_cluster_id
}

data "oci_core_subnet" "backup_subnet" {
  provider  = oci.resource
  subnet_id = data.oci_database_cloud_vm_cluster.this.backup_subnet_id
}

data "oci_limits_limit_values" "protected-database-backup-storage-gb" {
  provider       = oci.resource
  compartment_id = var.oci_tenancy_ocid
  service_name   = "autonomous-recovery-service"
  name           = "protected-database-backup-storage-gb"
}

data "oci_limits_limit_values" "protected-database-count" {
  provider       = oci.resource
  compartment_id = var.oci_tenancy_ocid
  service_name   = "autonomous-recovery-service"
  name           = "protected-database-count"
}
