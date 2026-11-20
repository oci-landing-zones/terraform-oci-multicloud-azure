locals {
  discovered_db_servers = sort([for server in data.azapi_resource_list.db_servers.output.value : server.properties.ocid])
  selected_db_servers   = var.db_servers != null ? sort(var.db_servers) : slice(local.discovered_db_servers, 0, min(var.db_server_count, length(local.discovered_db_servers)))
  subnet_id             = var.network_ids == null ? data.azapi_resource.network_anchor.output.properties.subnetId : var.network_ids.subnet_id
  vnet_id               = var.network_ids == null ? data.azapi_resource.network_anchor.output.properties.vnetId : var.network_ids.vnet_id
}

data "azapi_resource" "network_anchor" {
  type                   = "Oracle.Database/networkAnchors@2025-09-01"
  resource_id            = var.network_anchor_id
  response_export_values = ["properties", "zones"]
}

data "azapi_resource" "infrastructure" {
  type                   = "Oracle.Database/cloudExadataInfrastructures@2026-06-01"
  resource_id            = var.cloud_exadata_infrastructure_id
  response_export_values = ["properties", "zones"]
}

data "azapi_resource_list" "db_servers" {
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2026-06-01"
  parent_id              = var.cloud_exadata_infrastructure_id
  response_export_values = ["value"]
}

resource "azapi_resource" "this" {
  type      = "Oracle.Database/cloudVmClusters@2026-06-01"
  name      = var.name
  parent_id = var.resource_group_id
  location  = var.location
  tags      = var.tags
  replace_triggers_external_values = {
    resource_anchor_id = var.resource_anchor_id
    network_anchor_id  = var.network_anchor_id
    subnet_id          = local.subnet_id
    vnet_id            = local.vnet_id
    infrastructure_id  = var.cloud_exadata_infrastructure_id
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
      cloudExadataInfrastructureId = var.cloud_exadata_infrastructure_id
      vnetId                       = local.vnet_id
      subnetId                     = local.subnet_id
      displayName                  = var.name
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
    # Keep scope checks on the managed resource rather than on ID input
    # variables, so independent data reads do not depend on resource-group edits.
    precondition {
      condition = alltrue([
        for id in [var.resource_anchor_id, var.network_anchor_id, var.cloud_exadata_infrastructure_id, local.subnet_id, local.vnet_id] :
        lower(join("/", slice(split("/", id), 0, 5))) == lower(var.resource_group_id)
      ])
      error_message = "Resource Anchor, Network Anchor, infrastructure, subnet and VNet must be in the VM cluster's resource group and subscription."
    }
    precondition {
      condition     = var.db_servers != null || length(local.selected_db_servers) == var.db_server_count
      error_message = "New infrastructure must expose at least db_server_count DB servers before cluster creation. Retry after its server inventory is ready, or supply explicit db_servers."
    }
    precondition {
      condition     = alltrue([for id in local.selected_db_servers : contains(local.discovered_db_servers, id)])
      error_message = "Every db_servers OCI OCID must belong to the selected Exadata infrastructure."
    }
    precondition {
      condition = var.network_ids == null ? true : (
        lower(var.network_ids.subnet_id) == lower(data.azapi_resource.network_anchor.output.properties.subnetId) &&
        lower(var.network_ids.vnet_id) == lower(data.azapi_resource.network_anchor.output.properties.vnetId)
      )
      error_message = "Supplied network_ids must match the subnet and VNet returned by the selected Network Anchor."
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
      condition = (
        lower(data.azapi_resource.infrastructure.location) == lower(var.location) &&
        contains(data.azapi_resource.infrastructure.output.zones, var.availability_zone) &&
        try(lower(data.azapi_resource.infrastructure.output.properties.resourceAnchorId) == lower(var.resource_anchor_id), false)
      )
      error_message = "Infrastructure must match the selected region, zone and Resource Anchor."
    }
  }
}
