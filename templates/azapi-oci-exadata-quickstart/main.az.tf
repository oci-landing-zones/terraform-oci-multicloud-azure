locals {
  resource_group_id = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  infrastructure_id = var.existing_cloud_exadata_infrastructure_id == null ? module.infrastructure[0].id : var.existing_cloud_exadata_infrastructure_id
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

module "infrastructure" {
  count                = var.existing_cloud_exadata_infrastructure_id == null ? 1 : 0
  source               = "../../modules/azapi-ora-exadata-infra"
  resource_group_id    = local.resource_group_id
  resource_anchor_id   = var.resource_anchor_id
  name                 = var.infrastructure.name
  shape                = var.infrastructure.shape
  compute_count        = var.infrastructure.compute_count
  storage_count        = var.infrastructure.storage_count
  database_server_type = var.infrastructure.database_server_type
  storage_server_type  = var.infrastructure.storage_server_type
  location             = var.location
  availability_zone    = var.availability_zone
  tags                 = var.tags
}

module "vm_cluster" {
  source                          = "../../modules/azapi-ora-exadata-vmc"
  resource_group_id               = local.resource_group_id
  resource_anchor_id              = var.resource_anchor_id
  network_anchor_id               = var.network_anchor_id
  cloud_exadata_infrastructure_id = local.infrastructure_id
  name                            = var.vm_cluster_name
  location                        = var.location
  availability_zone               = var.availability_zone
  discover_db_servers             = var.existing_cloud_exadata_infrastructure_id == null
  db_servers                      = var.db_servers
  db_server_count                 = var.db_server_count
  hostname                        = var.hostname
  gi_version                      = var.gi_version
  ssh_public_keys                 = var.ssh_public_keys
  cpu_core_count                  = var.cpu_core_count
  memory_size_in_gbs              = var.memory_size_in_gbs
  db_node_storage_size_in_gbs     = var.db_node_storage_size_in_gbs
  data_storage_size_in_tbs        = var.data_storage_size_in_tbs
  data_storage_percentage         = var.data_storage_percentage
  license_model                   = var.license_model
  time_zone                       = var.time_zone
  is_local_backup_enabled         = var.is_local_backup_enabled
  is_sparse_diskgroup_enabled     = var.is_sparse_diskgroup_enabled
  data_collection_options         = var.data_collection_options
  tags                            = var.tags
}
