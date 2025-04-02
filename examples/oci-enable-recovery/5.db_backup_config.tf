# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

# Enable Automatic Backups to Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/enable-automatic-backup.html#GUID-B8A2D342-3331-42C9-8FDD-D0DB0E25F4CE
resource "oci_database_database" "exa_cdb" {
  # Depending on IAM policies, backup subnet registration and available limits 
  count = local.is_limit_available ? 1 : 0
  depends_on = [
    oci_recovery_recovery_service_subnet.this,
    module.recovery_service_iam_policies,
    oci_core_network_security_group_security_rule.nsg_rules
  ]

  provider   = oci.resource
  source     = "NONE"
  db_home_id = var.db_home_id
  database {
    db_name        = "DemoARS"
    admin_password = var.admin_password

    # Backup configurations
    db_backup_config {
      # Enable auto backup
      auto_backup_enabled       = true
      backup_deletion_policy    = "DELETE_AFTER_RETENTION_PERIOD"
      run_immediate_full_backup = true

      # Backup to Recovery Service 
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

output "oci_recovery_protected_database_id" {
  value = oci_database_database.exa_cdb[0].database[0].db_backup_config[0].backup_destination_details[0].id
}
