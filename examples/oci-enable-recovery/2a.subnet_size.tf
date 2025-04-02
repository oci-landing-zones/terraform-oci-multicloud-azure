# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

locals {
  compartment_id     = data.oci_database_cloud_vm_cluster.this.compartment_id
  vm_cluster_id      = data.oci_database_cloud_vm_cluster.this.id
  vcn_id             = data.oci_core_subnet.backup_subnet.vcn_id
  backup_subnet_id   = data.oci_core_subnet.backup_subnet.id
  backup_nsg_id      = length(data.oci_database_cloud_vm_cluster.this.backup_network_nsg_ids) == 1 ? data.oci_database_cloud_vm_cluster.this.backup_network_nsg_ids[0] : var.backup_network_nsg_id
  client_nsg_id      = length(data.oci_database_cloud_vm_cluster.this.nsg_ids) == 1 ? data.oci_database_cloud_vm_cluster.this.nsg_ids[0] : var.client_network_nsg_id

  # Subnet Size Requirements for Recovery Service: /24 (256 IP addresses) https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-1D4A9C7A-41D6-46A6-A401-E5381FA04548 
  is_backup_subnet_size_ok = tonumber(element(split("/", data.oci_core_subnet.backup_subnet.cidr_block), 1)) <= 24 ? true : false
}

data "oci_identity_regions" "this" {
  provider = oci.resource
}

data "oci_database_db_home" "this" {
  provider   = oci.resource
  db_home_id = var.db_home_id
}

data "oci_database_cloud_vm_cluster" "this" {
  provider            = oci.resource
  cloud_vm_cluster_id = data.oci_database_db_home.this.vm_cluster_id
}

data "oci_core_subnet" "client_subnet" {
  provider  = oci.resource
  subnet_id = data.oci_database_cloud_vm_cluster.this.subnet_id
}

data "oci_core_subnet" "backup_subnet" {
  provider  = oci.resource
  subnet_id = data.oci_database_cloud_vm_cluster.this.backup_subnet_id
}

output "check_backup_subnet" {
  value = {
    isBackupSubnetSizeOK = local.is_backup_subnet_size_ok
    backup_subnet_cidr   = data.oci_core_subnet.backup_subnet.cidr_block
  }
}
