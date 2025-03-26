# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html
locals {
  # Subnet size for Recovery Service /24 (256 IP addresses) https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-1D4A9C7A-41D6-46A6-A401-E5381FA04548 
  isBackupSubnetSizeOK = tonumber(element(split("/", data.oci_core_subnet.backup_subnet.cidr_block), 1)) <= 24 ? true : false

  compartment_id       = data.oci_database_cloud_vm_cluster.this.compartment_id
  vcn_id               = data.oci_core_subnet.backup_subnet.vcn_id
  backup_subnet_id     = data.oci_core_subnet.backup_subnet.id
  cluster_display_name = data.oci_database_cloud_vm_cluster.this.display_name
  vm_cluster_id        = data.oci_database_database.this.vm_cluster_id
}

# Register Recovery Service Subnet https://docs.oracle.com/en-us/iaas/recovery-service/doc/register-recovery-subnet.html#GUID-0311AC94-7802-4118-BEF5-AA127E3A1ACE
resource "oci_recovery_recovery_service_subnet" "this" {
  provider       = oci.resource
  compartment_id = local.compartment_id
  display_name   = local.cluster_display_name
  vcn_id         = local.vcn_id
  subnets        = [local.backup_subnet_id]
}

# Create Protection Policy https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-577DFDD8-7B28-4D92-8126-5AB7075B6FD2
resource "oci_recovery_protection_policy" "this" {
  provider                        = oci.resource
  compartment_id                  = local.compartment_id
  backup_retention_period_in_days = 14
  display_name                    = "Bronze_with_cloud_locality"
  must_enforce_cloud_locality     = true
}

output "oci_recovery_protection_policy_id" {
  value = oci_recovery_protection_policy.this.id
}

