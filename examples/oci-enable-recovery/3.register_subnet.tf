# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

# Register Recovery Service Subnet https://docs.oracle.com/en-us/iaas/recovery-service/doc/register-recovery-subnet.html#GUID-0311AC94-7802-4118-BEF5-AA127E3A1ACE
locals {
  cluster_display_name = data.oci_database_cloud_vm_cluster.this.display_name
}

resource "oci_recovery_recovery_service_subnet" "this" {
  count = local.is_backup_subnet_size_ok ? 1 : 0

  provider       = oci.resource
  compartment_id = local.compartment_id
  display_name   = local.cluster_display_name
  vcn_id         = local.vcn_id
  subnets        = [local.backup_subnet_id]
  nsg_ids        = [local.backup_nsg_id]
}

output "oci_recovery_service_subnet_id" {
  value = oci_recovery_recovery_service_subnet.this[0].id
}
