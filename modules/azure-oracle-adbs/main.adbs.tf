# Autonomous Database (Properties are read-only after creation)
resource "azapi_resource" "autonomous_db" {
  name = var.name
  type                      = "Oracle.Database/autonomousDatabases@2024-06-01"
  parent_id                 = data.azurerm_resource_group.resource_group.id
  schema_validation_enabled = false

  timeouts {
    create = "3h"
    update = "2h"
    delete = "1h"
  }

  body = {
    "location" : var.location,
    "properties" : {
      "adminPassword" : var.admin_password,
      "dataBaseType" : "Regular",
      "displayName" : var.display_name,
      "dbVersion" : var.db_version,
      "dbWorkload" : var.db_workload,
      "licenseModel" : var.license_model,
      "computeModel" : var.compute_model,

      # "cpuCoreCount" = var.cpu_core_count,
      "computeCount" : var.compute_count,
      "dataStorageSizeInTbs" : var.data_storage_size_in_tbs,

      "characterSet" : var.character_set,
      "ncharacterSet" : var.national_character_set,

      "isAutoScalingEnabled" : var.auto_scaling_enabled,
      "isAutoScalingForStorageEnabled" : var.auto_scaling_for_storage_enabled,
      "isMtlsConnectionRequired" : var.mtls_connection_required

      "vnetId" : data.azurerm_virtual_network.virtual_network.id
      "subnetId" : data.azurerm_subnet.subnet.id
      "backupRetentionPeriodInDays" : var.backup_retention_period_in_days

      "openMode" : var.open_mode
      "permissionLevel" : var.permission_level
      "whitelistedIps" : var.whitelisted_ips
    }
    "tags" : var.tags
  }
  response_export_values = ["id", "properties.ocid", "properties"]

  lifecycle {
    ignore_changes = all
  }
}

# Wait until ADB become available state
resource "null_resource" "wait_until_available" {
    depends_on = [azapi_resource.autonomous_db]

    provisioner "local-exec" {
        command = "az extension add --name oracle-database | az oracle-database autonomous-database wait --custom lifecycleState=='Available' --ids ${azapi_resource.autonomous_db.id}"
    }
}

## Uncomment for updating properties using azapi_resource_action with PATCH
# resource "azapi_resource_action" "resource_allocation"{
#   depends_on = [ azapi_resource.autonomous_db, null_resource.wait_until_available ]
#   type                      = "Oracle.Database/autonomousDatabases@2024-06-01"
#   resource_id = azapi_resource.autonomous_db.id
#   method      = "PATCH"
#   body = {
#     "properties" : {
#       "backupRetentionPeriodInDays" : var.backup_retention_period_in_days
#       "computeCount" = var.compute_count
#       "dataStorageSizeInTbs" = var.data_storage_size_in_tbs
#       "isAutoScalingEnabled" = var.auto_scaling_enabled
#       "isAutoScalingForStorageEnabled" = var.auto_scaling_for_storage_enabled

#       ## Update is not supported from Azure at this time. Please use OCI Console / API.
#       # "customerContacts" = var.customer_contacts 
#       # "displayName" : var.display_name 
#       # "cpuCoreCount" = var.cpu_core_count 
#       # "adminPassword" = var.admin_password, 
#       # "licenseModel" = var.license_model, 
#       # "isMtlsConnectionRequired"= var.mtls_connection_required 
#       # "openMode" = var.open_mode 
#       # "permissionLevel" = var.permission_level

#       ## Non-updatable properties
#       # "dataBaseType" = "Regular",
#       # "dbVersion" = var.db_version,
#       # "dbWorkload" = var.db_workload,
#       # "computeModel" = var.compute_model,
#       # "characterSet" = var.character_set,
#       # "ncharacterSet" = var.national_character_set,
#       # "vnetId" = data.azurerm_virtual_network.virtual_network.id
#       # "subnetId" = data.azurerm_subnet.subnet.id
#     }
#   }
# }

## Uncomment for updating DR configurations
## (Seperate from other updates as cannot scale and update the database at the same time)
# resource "azapi_resource_action" "disaster_recovery"{
#   depends_on = [ azapi_resource_action.resource_allocation]
#   type                      = "Oracle.Database/autonomousDatabases@2024-06-01"
#   resource_id = azapi_resource.autonomous_db.id
#   method      = "PATCH"
#   body = {
#     "properties" : {
#       "isLocalDataGuardEnabled" = var.local_dataguard_enabled
#       "localAdgAutoFailoverMaxDataLossLimit" = var.local_adg_auto_failover_max_data_loss_limit
#     }
#   }
# }

## Uncomment for updating Azure Tags
## (Seperate from other updates as cannot have updates for both Autonomous Database properties and Tags in the same request)
# resource "azapi_resource_action" "tags"{
#   depends_on = [ azapi_resource_action.disaster_recovery ]
#   type                      = "Oracle.Database/autonomousDatabases@2024-06-01"
#   resource_id = azapi_resource.autonomous_db.id
#   method      = "PATCH"
#   body = {
#     "tags" : var.tags
#   }
# }

## WhitelistedIps cannot be updated in parallel with any of the following: 
## licenseModel, dbEdition, cpuCoreCount, computeCount, computeModel, adminPassword, isMTLSConnectionRequired, openMode, permissionLevel, dbWorkload, dbVersion, isRefreshable, dbName, scheduledOperations, dbToolsDetails, isLocalDataGuardEnabled, or isFreeTier.
# resource "azapi_resource_action" "whitelistedIps"{
#   depends_on  = [ azapi_resource.autonomous_db ]
#   type        = "Oracle.Database/autonomousDatabases@2024-06-01"
#   resource_id = azapi_resource.autonomous_db.id
#   method      = "PATCH"
#   body = {
#     "properties" : {
#       "whitelistedIps" = var.whitelisted_ips
#     }
#   }
# }