resource "azurerm_resource_group" "resource_group" {
  location = var.location
  name     = var.resource_group_name
}

# Delete comment before merge
# Reference code : https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork/blob/5b60a9a29fa471d3298427f706645e80f09de9da/examples/legacy_address_prefix/README.md 
module "avm_vmc_network" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.2.4"

  address_space       = var.virtual_network_address_space
  location            = var.location
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.resource_group.name

  subnets = {
    delegated = {
      name             = var.delegated_subnet_name
      address_prefixes = var.delegated_subnet_address_prefix

      delegation = [{
        name = "Oracle.Database/networkAttachments"
        service_delegation = {
          name    = "Oracle.Database/networkAttachments"
          actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]

        }
      }]
    }
  }
}

module "exa_infra_and_vm_cluster" {
  source = "../../modules/azure-exainfra-vmcluster"
  providers = {
    azapi = azapi
  }
  depends_on = [module.avm_vmc_network]

  exadata_infrastructure_resource_display_name                     = var.exadata_infrastructure_resource_display_name
  exadata_infrastructure_resource_name                             = var.exadata_infrastructure_resource_name
  location                                                         = var.location
  oracle_database_delegated_subnet_id                              = module.avm_vmc_network.subnets[0].id
  resource_group_id                                                = azurerm_resource_group.resource_group.id
  ssh_public_key                                                   = var.ssh_public_key
  vm_cluster_display_name                                          = var.vm_cluster_display_name
  vm_cluster_resource_name                                         = var.vm_cluster_resource_name
  vnet_id                                                          = module.avm_vmc_network.resource_id
  zones                                                            = var.zones
  exadata_infrastructure_compute_cpu_count                         = var.exadata_infrastructure_compute_cpu_count
  exadata_infrastructure_maintenance_window_lead_time_in_weeks     = var.exadata_infrastructure_maintenance_window_lead_time_in_weeks
  exadata_infrastructure_maintenance_window_patching_mode          = var.exadata_infrastructure_maintenance_window_patching_mode
  exadata_infrastructure_maintenance_window_preference             = var.exadata_infrastructure_maintenance_window_preference
  exadata_infrastructure_shape                                     = var.exadata_infrastructure_shape
  vm_cluster_cpu_core_count                                        = var.vm_cluster_cpu_core_count
  vm_cluster_data_collection_options_is_diagnostics_events_enabled = var.vm_cluster_data_collection_options_is_diagnostics_events_enabled
  vm_cluster_data_collection_options_is_health_monitoring_enabled  = var.vm_cluster_data_collection_options_is_health_monitoring_enabled
  vm_cluster_data_collection_options_is_incident_logs_enabled      = var.vm_cluster_data_collection_options_is_incident_logs_enabled
  vm_cluster_data_storage_percentage                               = var.vm_cluster_data_storage_percentage
  vm_cluster_data_storage_size_in_tbs                              = var.vm_cluster_data_storage_size_in_tbs
  vm_cluster_db_node_storage_size_in_gbs                           = var.vm_cluster_db_node_storage_size_in_gbs
  vm_cluster_gi_version                                            = var.vm_cluster_gi_version
  vm_cluster_hostname                                              = var.vm_cluster_hostname
  vm_cluster_is_local_backup_enabled                               = var.vm_cluster_is_local_backup_enabled
  vm_cluster_is_sparse_diskgroup_enabled                           = var.vm_cluster_is_sparse_diskgroup_enabled
  vm_cluster_license_model                                         = var.vm_cluster_license_model
  vm_cluster_memory_size_in_gbs                                    = var.vm_cluster_memory_size_in_gbs
  vm_cluster_time_zone                                             = var.vm_cluster_time_zone
  exadata_infrastructure_storage_count                             = var.exadata_infrastructure_storage_count
}

module "db_home_and_cdb_pdb" {
  source = "../../modules/oci-db-home-cdb-pdb"
  providers = {
    oci = oci.oci-st
  }
  db_admin_password    = var.db_admin_password
  db_home_display_name = var.db_home_display_name
  db_name              = var.db_name
  pdb_name             = var.pdb_name
  region               = var.region
  vm_cluster_ocid      = module.exa_infra_and_vm_cluster.vm_cluster_ocid
  db_home_source       = var.db_home_source
  db_source            = var.db_source
  db_version           = var.db_version
}