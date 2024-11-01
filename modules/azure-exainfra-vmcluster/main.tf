terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}



resource "azapi_resource" "cloudExadataInfrastructure" {
  type      = "Oracle.Database/cloudExadataInfrastructures@2023-09-01"
  parent_id = var.resource_group_id
  name      = var.exadata_infrastructure_name
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
      "displayName" : var.exadata_infrastructure_name,
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
  lifecycle {
    ignore_changes = [
      body.properties.computeCount,
      body.properties.storageCount,
      body.properties.maintenanceWindow.leadTimeInWeeks,
      body.properties.maintenanceWindow.preference,
      body.properties.maintenanceWindow.patchingMode
    ]
  }
}



module "az_vmcluster" {
  source = "../azure-vmcluster"
  providers = {
    azapi = azapi
  }

  exadata_infrastructure_id = azapi_resource.cloudExadataInfrastructure.id
  #exadata_infra_dbserver_ocids = var.exadata_infra_dbserver_ocids # for default value of all dbservers
  location                                                         = var.location
  resource_group_id                                                = var.resource_group_id
  vnet_id                                                          = var.vnet_id
  oracle_database_delegated_subnet_id                              = var.oracle_database_delegated_subnet_id
  vm_cluster_name                                                  = var.vm_cluster_name
  # vm_cluster_resource_name                                         = var.vm_cluster_resource_name
  # vm_cluster_display_name                                          = var.vm_cluster_display_name
  vm_cluster_gi_version                                            = var.vm_cluster_gi_version
  vm_cluster_hostname                                              = var.vm_cluster_hostname
  vm_cluster_cpu_core_count                                        = var.vm_cluster_cpu_core_count
  vm_cluster_data_collection_options_is_diagnostics_events_enabled = var.vm_cluster_data_collection_options_is_diagnostics_events_enabled
  vm_cluster_data_collection_options_is_health_monitoring_enabled  = var.vm_cluster_data_collection_options_is_health_monitoring_enabled
  vm_cluster_data_collection_options_is_incident_logs_enabled      = var.vm_cluster_data_collection_options_is_incident_logs_enabled
  vm_cluster_data_storage_percentage                               = var.vm_cluster_data_storage_percentage
  vm_cluster_data_storage_size_in_tbs                              = var.vm_cluster_data_storage_size_in_tbs
  vm_cluster_db_node_storage_size_in_gbs                           = var.vm_cluster_db_node_storage_size_in_gbs
  vm_cluster_license_model                                         = var.vm_cluster_license_model
  vm_cluster_memory_size_in_gbs                                    = var.vm_cluster_memory_size_in_gbs
  vm_cluster_time_zone                                             = var.vm_cluster_time_zone
  vm_cluster_is_local_backup_enabled                               = var.vm_cluster_is_local_backup_enabled
  vm_cluster_is_sparse_diskgroup_enabled                           = var.vm_cluster_is_sparse_diskgroup_enabled
  vm_cluster_ssh_public_key                                        = var.vm_cluster_ssh_public_key
  nsg_cidrs                                                        = var.nsg_cidrs
}
