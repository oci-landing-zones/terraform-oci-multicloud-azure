resource "azapi_resource" "this" {
  type      = "Oracle.Database/cloudExadataInfrastructures@2026-06-01"
  name      = var.name
  parent_id = var.resource_group_id
  location  = var.location
  tags      = var.tags
  replace_triggers_external_values = {
    resource_anchor_id   = var.resource_anchor_id
    zone                 = var.availability_zone
    shape                = var.shape
    database_server_type = var.database_server_type
    storage_server_type  = var.storage_server_type
  }
  body = {
    zones = [var.availability_zone]
    properties = merge(
      {
        resourceAnchorId = var.resource_anchor_id
        displayName      = var.name
        shape            = var.shape
        computeCount     = var.compute_count
        storageCount     = var.storage_count
        maintenanceWindow = {
          preference   = "NoPreference"
          patchingMode = "Rolling"
        }
      },
      var.database_server_type == null ? {} : { databaseServerType = var.database_server_type },
      var.storage_server_type == null ? {} : { storageServerType = var.storage_server_type },
    )
  }
  response_export_values = ["properties.ocid"]
  timeouts {
    create = "24h"
    update = "24h"
    delete = "24h"
  }
}
