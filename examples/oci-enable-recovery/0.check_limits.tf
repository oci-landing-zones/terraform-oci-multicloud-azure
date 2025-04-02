# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

# Review Limits for Recovery Service
# https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-9D84AD3B-AB82-4891-B656-A18E9A5C8491

locals {
    limit_remain_ars_storage_gb = data.oci_limits_resource_availability.protected-database-backup-storage-gb.available
    limit_remain_ars_dbcount = data.oci_limits_resource_availability.protected-database-count.available
    is_limit_available = (local.limit_remain_ars_storage_gb > 0) && (local.limit_remain_ars_dbcount > 0)
    subscription_id = data.external.get_subscription.result.id
}

data "external" "get_subscription" {
  program = ["bash","${path.module}/scripts/get_subscription.sh"]
}

data "oci_limits_resource_availability" "protected-database-backup-storage-gb" {
  provider        = oci.resource
  compartment_id  = var.oci_tenancy_ocid
  limit_name      = "protected-database-backup-storage-gb"
  service_name    = "autonomous-recovery-service"
  subscription_id = local.subscription_id
}

data "oci_limits_resource_availability" "protected-database-count" {
  provider        = oci.resource
  compartment_id  = var.oci_tenancy_ocid
  limit_name      = "protected-database-count"
  service_name    = "autonomous-recovery-service"
  subscription_id = local.subscription_id
}

output "check_ars_limits" {
  value = {
    is_ars_limit_available = local.is_limit_available
    ars_limit_remain_dbcount = local.limit_remain_ars_dbcount
    ars_limit_remain_storage = local.limit_remain_ars_storage_gb
  }
}
