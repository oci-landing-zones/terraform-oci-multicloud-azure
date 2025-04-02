# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

# Permissions Required for Multicloud Oracle Databases to Use Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-A4BCD98E-A450-4379-9213-4E8D6414AC85
module "recovery_service_iam_policies" {
  source       = "github.com/oci-landing-zones/terraform-oci-modules-iam//policies?ref=release-0.2.8"
  providers = {
    oci = oci.home
  }

  tenancy_ocid = var.oci_tenancy_ocid
  policies_configuration = {
    supplied_policies : {
      "ARS-POLICY" : {
        name : "recovery-service-policy-azure"
        description : "Permissions Required for Oracle Database@Google Cloud to use Recovery Service for backups"
        compartment_id : var.oci_tenancy_ocid
        statements : [
          "allow service database to manage recovery-service-family in tenancy",
          "allow service database to manage tagnamespace in tenancy",
          "allow service rcs to manage recovery-service-family in tenancy",
          "allow service rcs to manage virtual-network-family in tenancy",
          "allow service database to use organizations-assigned-subscription in tenancy where target.subscription.servicename = 'ORACLEDBATAZURE'",
          "allow group ${var.recovery_service_admin_grps} to manage recovery-service-family in tenancy"
        ]
      }
    }
  }
}