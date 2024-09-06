resource "azurerm_resource_group" "az_rg" {
  name     = var.resource_group
  location = var.location
}


resource "azapi_resource" "cloudExadataInfrastructure" {
  type      = "Oracle.Database/cloudExadataInfrastructures@2023-09-01"
  parent_id = azurerm_resource_group.az_rg.id
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
      "displayName" : var.exadata_infrastructure_resource_name,
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