terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}


data "azapi_resource_list" "listDbServersByCloudExadataInfrastructure" {
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2023-09-01"
  parent_id              = var.exadata_infrastructure_id
  response_export_values = ["*"]
}


locals {
  exa_infra_dbServers       = jsondecode(data.azapi_resource_list.listDbServersByCloudExadataInfrastructure.output).value[*]
  exa_infra_dbServers_ocids = toset([for dbs in local.exa_infra_dbServers : "${dbs.properties.ocid}"])


  # use supplied dbservers if provided else use exa.dbservers
  are_dbservers_provided = (length(var.exadata_infra_dbserver_ocids) == 0)
  db_server_ocids        = local.are_dbservers_provided ? local.exa_infra_dbServers_ocids : var.exadata_infra_dbserver_ocids
}

resource "azapi_resource" "cloudVmCluster" {
  type                      = "Oracle.Database/cloudVmClusters@2023-09-01"
  parent_id                 = var.resource_group_id
  name                      = var.vm_cluster_resource_name
  schema_validation_enabled = false
  timeouts {
    create = "6h30m"
    delete = "1h"
  }
  body = {
    "location" : var.location,
    "properties" : {
      "subnetId" : var.oracle_database_delegated_subnet_id
      "cloudExadataInfrastructureId" : var.exadata_infrastructure_id
      "cpuCoreCount" : var.vm_cluster_cpu_core_count
      "dataCollectionOptions" : {
        "isDiagnosticsEventsEnabled" : var.vm_cluster_data_collection_options_is_diagnostics_events_enabled,
        "isHealthMonitoringEnabled" : var.vm_cluster_data_collection_options_is_health_monitoring_enabled,
        "isIncidentLogsEnabled" : var.vm_cluster_data_collection_options_is_incident_logs_enabled
      },
      "dataStoragePercentage" : var.vm_cluster_data_storage_percentage,
      "dataStorageSizeInTbs" : var.vm_cluster_data_storage_size_in_tbs,
      "dbNodeStorageSizeInGbs" : var.vm_cluster_db_node_storage_size_in_gbs,
      "dbServers" : local.db_server_ocids
      "displayName" : var.vm_cluster_display_name,
      "giVersion" : var.vm_cluster_gi_version,
      "hostname" : var.vm_cluster_hostname,
      "isLocalBackupEnabled" : var.vm_cluster_is_local_backup_enabled,
      "isSparseDiskgroupEnabled" : var.vm_cluster_is_sparse_diskgroup_enabled,
      "licenseModel" : var.vm_cluster_license_model
      "memorySizeInGbs" : var.vm_cluster_memory_size_in_gbs,
      "sshPublicKeys" : [var.vm_cluster_ssh_public_key],
      "timeZone" : var.vm_cluster_time_zone,
      "vnetId" : var.vnet_id
    }
  }
  response_export_values = ["properties.ocid"]
  lifecycle {
    ignore_changes = [
      body.properties.giVersion, body.properties.hostname
    ]
  }
}