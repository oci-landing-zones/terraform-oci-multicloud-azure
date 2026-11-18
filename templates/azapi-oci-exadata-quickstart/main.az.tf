locals {
  resource_group_id = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  infrastructure_id = var.existing_cloud_exadata_infrastructure_id == null ? azapi_resource.infrastructure[0].id : var.existing_cloud_exadata_infrastructure_id
  # The VM cluster API still requires both IDs even when networkAnchorId is set.
  # Read them from the selected anchor so there is a single network source of truth.
  # Discover OCI DB server IDs, not their Azure child resource IDs. Automatic
  # selection is limited to new dedicated infrastructure created by this state.
  discovered_db_servers = sort([for server in data.azapi_resource_list.db_servers.output.value : server.properties.ocid])
  selected_db_servers   = var.db_servers != null ? sort(var.db_servers) : slice(local.discovered_db_servers, 0, min(var.db_server_count, length(local.discovered_db_servers)))

  subnet_id = data.azapi_resource.network_anchor.output.properties.subnetId
  vnet_id   = data.azapi_resource.network_anchor.output.properties.vnetId
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

data "azapi_resource" "network_anchor" {
  type                   = "Oracle.Database/networkAnchors@2025-09-01"
  resource_id            = var.network_anchor_id
  response_export_values = ["properties", "zones"]
}

data "azapi_resource" "infrastructure" {
  count                  = var.existing_cloud_exadata_infrastructure_id == null ? 0 : 1
  type                   = "Oracle.Database/cloudExadataInfrastructures@2026-06-01"
  resource_id            = var.existing_cloud_exadata_infrastructure_id
  response_export_values = ["properties", "zones"]
}

data "azapi_resource_list" "db_servers" {
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2026-06-01"
  parent_id              = local.infrastructure_id
  response_export_values = ["value"]
}

resource "azapi_resource" "infrastructure" {
  count     = var.existing_cloud_exadata_infrastructure_id == null ? 1 : 0
  type      = "Oracle.Database/cloudExadataInfrastructures@2026-06-01"
  name      = var.infrastructure.name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags
  replace_triggers_external_values = {
    resource_anchor_id = var.resource_anchor_id
    zone               = var.availability_zone
    shape              = var.infrastructure.shape
  }
  body = {
    zones = [var.availability_zone]
    properties = {
      resourceAnchorId = var.resource_anchor_id
      displayName      = var.infrastructure.name
      shape            = var.infrastructure.shape
      computeCount     = var.infrastructure.compute_count
      storageCount     = var.infrastructure.storage_count
      maintenanceWindow = {
        preference   = "NoPreference"
        patchingMode = "Rolling"
      }
    }
  }
  response_export_values = ["properties.ocid"]
  timeouts {
    create = "24h"
    update = "24h"
    delete = "24h"
  }
}

resource "azapi_resource" "vm_cluster" {
  type      = "Oracle.Database/cloudVmClusters@2026-06-01"
  name      = var.vm_cluster_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags
  replace_triggers_external_values = {
    resource_anchor_id = var.resource_anchor_id
    network_anchor_id  = var.network_anchor_id
    subnet_id          = local.subnet_id
    vnet_id            = local.vnet_id
    infrastructure_id  = local.infrastructure_id
    db_servers         = local.selected_db_servers
    hostname           = var.hostname
    gi_version         = var.gi_version
    zone               = var.availability_zone
    time_zone          = var.time_zone
    storage_percentage = var.data_storage_percentage
    local_backup       = var.is_local_backup_enabled
    sparse_diskgroup   = var.is_sparse_diskgroup_enabled
  }
  body = {
    properties = {
      resourceAnchorId             = var.resource_anchor_id
      networkAnchorId              = var.network_anchor_id
      cloudExadataInfrastructureId = local.infrastructure_id
      vnetId                       = local.vnet_id
      subnetId                     = local.subnet_id
      displayName                  = var.vm_cluster_name
      dbServers                    = local.selected_db_servers
      hostname                     = var.hostname
      giVersion                    = var.gi_version
      sshPublicKeys                = var.ssh_public_keys
      cpuCoreCount                 = var.cpu_core_count
      memorySizeInGbs              = var.memory_size_in_gbs
      dbNodeStorageSizeInGbs       = var.db_node_storage_size_in_gbs
      dataStorageSizeInTbs         = var.data_storage_size_in_tbs
      dataStoragePercentage        = var.data_storage_percentage
      licenseModel                 = var.license_model
      timeZone                     = var.time_zone
      isLocalBackupEnabled         = var.is_local_backup_enabled
      isSparseDiskgroupEnabled     = var.is_sparse_diskgroup_enabled
      dataCollectionOptions = {
        isDiagnosticsEventsEnabled = var.data_collection_options.diagnostics_events_enabled
        isHealthMonitoringEnabled  = var.data_collection_options.health_monitoring_enabled
        isIncidentLogsEnabled      = var.data_collection_options.incident_logs_enabled
      }
    }
  }
  response_export_values = ["properties.ocid"]
  timeouts {
    create = "24h"
    update = "24h"
    delete = "24h"
  }
  lifecycle {
    precondition {
      condition     = var.db_servers != null || length(local.selected_db_servers) == var.db_server_count
      error_message = "New infrastructure must expose at least db_server_count DB servers before cluster creation. Retry after its server inventory is ready, or supply explicit db_servers."
    }
    precondition {
      condition     = alltrue([for id in local.selected_db_servers : contains(local.discovered_db_servers, id)])
      error_message = "Every db_servers OCI OCID must belong to the selected Exadata infrastructure."
    }
    precondition {
      condition     = lower(data.azapi_resource.network_anchor.output.properties.resourceAnchorId) == lower(var.resource_anchor_id)
      error_message = "The Network Anchor must be associated with the selected Resource Anchor."
    }
    precondition {
      condition     = lower(data.azapi_resource.network_anchor.location) == lower(var.location) && contains(data.azapi_resource.network_anchor.output.zones, var.availability_zone)
      error_message = "The Network Anchor must match the selected region and availability zone."
    }
    precondition {
      condition = var.existing_cloud_exadata_infrastructure_id == null ? true : (
        lower(data.azapi_resource.infrastructure[0].location) == lower(var.location) &&
        contains(data.azapi_resource.infrastructure[0].output.zones, var.availability_zone) &&
        try(lower(data.azapi_resource.infrastructure[0].output.properties.resourceAnchorId) == lower(var.resource_anchor_id), false)
      )
      error_message = "Existing infrastructure must match the selected region, zone and Resource Anchor."
    }
  }
}
