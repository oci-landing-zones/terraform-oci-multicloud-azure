terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azapi_resource" "cloudExadataInfrastructure" {
  type      = "Oracle.Database/cloudExadataInfrastructures@2023-09-01-preview"
  parent_id = var.resource_group_id
  name      = var.exadata_infrastructure_resource_name
  timeouts {
    create = "1h30m"
    delete = "20m"
  }
  body = {
    "location" : var.location,
    "zones" : [
      var.zones
    ],
    "properties" : {
      "computeCount" : var.exadata_infrastructure_compute_cpu_count,
      "displayName" : var.exadata_infrastructure_resource_display_name,
      "maintenanceWindow" : {
        "leadTimeInWeeks" : var.exadata_infrastructure_maintenance_window_lead_time_in_weeks,
        "preference" : var.exadata_infrastructure_maintenance_window_preference,
        "patchingMode" : var.exadata_infrastructure_maintenance_window_patching_mode
      },
      "shape" : var.exadata_infrastructure_shape,
      "storageCount" : var.exadata_infrastructure_storage_count
    }
  }
  schema_validation_enabled = false
}

data "azapi_resource_list" "listDbServersByCloudExadataInfrastructure" {
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2023-09-01-preview"
  parent_id              = azapi_resource.cloudExadataInfrastructure.id
  response_export_values = ["*"]
}

resource "azapi_resource" "cloudVmCluster" {
  type                      = "Oracle.Database/cloudVmClusters@2023-09-01-preview"
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
      "cloudExadataInfrastructureId" : azapi_resource.cloudExadataInfrastructure.id
      "cpuCoreCount" : var.vm_cluster_cpu_core_count
      "dataCollectionOptions" : {
        "isDiagnosticsEventsEnabled" : var.vm_cluster_data_collection_options_is_diagnostics_events_enabled,
        "isHealthMonitoringEnabled" : var.vm_cluster_data_collection_options_is_health_monitoring_enabled,
        "isIncidentLogsEnabled" : var.vm_cluster_data_collection_options_is_incident_logs_enabled
      },
      "dataStoragePercentage" : var.vm_cluster_data_storage_percentage,
      "dataStorageSizeInTbs" : var.vm_cluster_data_storage_size_in_tbs,
      "dbNodeStorageSizeInGbs" : var.vm_cluster_db_node_storage_size_in_gbs,
      "dbServers" : [
        jsondecode(data.azapi_resource_list.listDbServersByCloudExadataInfrastructure.output).value[0].properties.ocid,
        jsondecode(data.azapi_resource_list.listDbServersByCloudExadataInfrastructure.output).value[1].properties.ocid
      ]
      "displayName" : var.vm_cluster_display_name,
      "giVersion" : var.vm_cluster_gi_version,
      "hostname" : var.vm_cluster_hostname,
      "isLocalBackupEnabled" : var.vm_cluster_is_local_backup_enabled,
      "isSparseDiskgroupEnabled" : var.vm_cluster_is_sparse_diskgroup_enabled,
      "licenseModel" : var.vm_cluster_license_model
      "memorySizeInGbs" : var.vm_cluster_memory_size_in_gbs,
      "sshPublicKeys" : [var.ssh_public_key],
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