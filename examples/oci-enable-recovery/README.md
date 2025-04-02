# Backup Oracle Database@Azure using Recovery Service in Azure

- This example is to illustrate how to configure Recovery Service@Azure for Oracle Database@Azure using Terraform. Please refer to [this document](https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html) for details

> [!NOTE]
> This example is not aimed as a reusable module, please refactor and customize them for fitting into your own devops pipeline.

![](https://docs.oracle.com/en-us/iaas/recovery-service/doc/img/primaryworkflow.png)

## 0. Ensure your tenancy's resource limits for Recovery Service are adequate

- Make sure you have enough [resource limit for Recovery Service](https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#DBRSU-GUID-9D84AD3B-AB82-4891-B656-A18E9A5C8491) with your ORACLEDBATAZURE subscription.
- Both "Protected Database Count" and "Space Used for Recovery Window (GB)" should be available in your region.
- You can also check the available limit via [OCI Console](https://cloud.oracle.com/limits)
- [0.check_limits.tf](0.check_limits.tf) is illustrating how you can check the limit with Terraform, which make use of [OCI CLI](./scripts/get_subscription.sh) to enquire the ORACLEDBATAZURE subscription ID.

## 1. Create IAM policies for Recovery Service 
- Make sure the [Policy Statements Required for Using Recovery Service](https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-867093E8-DBC2-4FD1-9002-5A5722749F9E__GUID-62E1AACF-1BD2-4038-8503-3E6B186F76C9) are provisioned 
- [1.iam_policies.tf](./1.iam_policies.tf) is illustrating how you can provision those IAM Policies using Terraform, using OCI Landing Zone IAM module.

## 2. Configuring Network Resources for Recovery Service

### Review Subnet Size Requirements and Security Rules for Recovery Service Subnet
- Use an IP4-only subnet in the database VCN for Recovery Service operations.
- Check if the backup subnet meets the recommended /24 subnet size requirement
- [2a.subnet_size.tf](./2a.subnet_size.tf) is illustrating the subnet size checking using Terraform.

### Config NSG rules
- Configure NSG to [allow traffic to port 8005 and 2484 in the backup subnet ](https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-9CD51C49-117B-4449-8A39-68CE8822E63B) from both client and backup subnet
- [2.subnet_nsg.tf](./2b.subnet_nsg.tf) is illustrating the NSG rule creation using Terraform

## 3. Register Recovery Service subnet
- [Register the backup subnet and the NSG with Recovery Service](https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#DBRSU-GUID-78D403AF-D1DF-4229-B051-3B39EA42D6CD)
- [3.register_subnet.tf](./3.register_subnet.tf) is illustrating the backup subnet and NSG registration with Recovery Service using Terraform
```terraform
resource "oci_recovery_recovery_service_subnet" "this" {
  provider       = oci.resource
  compartment_id = local.compartment_id
  display_name   = local.cluster_display_name
  vcn_id         = local.vcn_id
  subnets        = [local.backup_subnet_id]
  nsg_ids        = [local.backup_nsg_id]
}
```

## 4. Create Recovery Policy with locality enforcement
- Recovery Service creates protected databases and related backups in Oracle Cloud by default. 
- You can override this default behavior for your multicloud Oracle Databases, such as Oracle Database@Azure, by [enforcing Cloud Locality]((https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/recovery_protection_policy#must_enforce_cloud_locality-1)) in the Protection Policy. 
- Please refer to this [document](https://docs.oracle.com/en-us/iaas/recovery-service/doc/azure-multicloud-recoveryservice.html) for details.
- [4.recovery_policy.tf](./4.recovery_policy.tf) is illustrating the recovery policy creation using Terraform
```terraform
resource "oci_recovery_protection_policy" "this" {
  ...
  must_enforce_cloud_locality     = true
}
```

## 5. Configure Database Backup Destination
- After all the prerequisite checking and configuration, you can configure the database backup to use recovery service at Azure by referring to the recovery policy ID that enforce cloud locality.
- Since the VPC user will be updated after the configuration, we need to include this in the ignore_changes block to maintain Terraform impoentcy. 
- [5.db_backup_config.tf](./5.db_backup_config.tf) is illustrating how you can configure the DB backup with the Recovery Service. 
```terraform
resource "oci_database_database" "this" {
  ...
  database {
    ...
    db_backup_config {
      auto_backup_enabled       = true
      ...
      backup_destination_details {
        dbrs_policy_id = oci_recovery_protection_policy.this.id
        type           = "DBRS"
      }
    }
  }
  lifecycle {
    # For impoentcy
    ignore_changes = [database[0].db_backup_config[0].backup_destination_details[0].vpc_user]
  }
}
```
