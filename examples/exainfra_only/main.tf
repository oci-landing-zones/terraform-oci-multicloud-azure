module "azure-exainfra" {
  source                                                       = "../../modules/azure-exainfra"
  resource_group                                               = "tftest-01"
  location                                                     = "eastus"
  zones                                                        = "3"
  exadata_infrastructure_resource_name                         = "tftest-01"
  exadata_infrastructure_shape                                 = "Exadata.X9M"
  exadata_infrastructure_compute_cpu_count                     = 2
  exadata_infrastructure_storage_count                         = 3
  exadata_infrastructure_maintenance_window_lead_time_in_weeks = 0
  exadata_infrastructure_maintenance_window_preference         = "NoPreference"
  exadata_infrastructure_maintenance_window_patching_mode      = "Rolling"
}