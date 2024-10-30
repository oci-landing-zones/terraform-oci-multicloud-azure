terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

provider "azapi" {}




module "avm_vmc_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.2.4"

  address_space       = [var.virtual_network_address_space]
  location            = var.location
  name                = var.virtual_network_name
  resource_group_name = var.network_resource_group_name

  subnets = {
    delegated = {
      name             = var.delegated_subnet_name
      address_prefixes = [var.delegated_subnet_address_prefix]

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




module "az_vmcluster" {
  source = "../../modules/azure-vmcluster"
  providers = {
    azapi = azapi
  }
  depends_on = [module.avm_vmc_network]

  exadata_infrastructure_id                                        = var.exadata_infrastructure_id
  exadata_infra_dbserver_ocids                                     = var.exadata_infra_dbserver_ocids
  location                                                         = var.location
  resource_group_id                                                = var.resource_group_id
  vnet_id                                                          = module.avm_vmc_network.resource_id
  oracle_database_delegated_subnet_id                              = module.avm_vmc_network.subnets.delegated.resource_id
  vm_cluster_resource_name                                         = var.vm_cluster_resource_name
  vm_cluster_display_name                                          = var.vm_cluster_display_name
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

}

