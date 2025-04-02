# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

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

