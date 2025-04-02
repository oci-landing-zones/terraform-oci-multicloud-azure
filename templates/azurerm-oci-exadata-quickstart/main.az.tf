provider "azurerm" {
  features {}
}

locals {
  # avm_enable_telemetry = var.avm_enable_telemetry
  az_tags = var.common_tags
  az_region   = var.az_region
  az_zone     = var.az_zone
  exadata_infrastructure_name = "${var.exadata_infrastructure_name}-${random_string.suffix.result}"
  vm_cluster_name     = "${var.vm_cluster_name}-${random_string.suffix.result}"
  vm_cluster_hostname = "${var.vm_cluster_hostname}-${random_string.suffix.result}"
  # vm_cluster_domain = "oci${substr(replace(var.delegated_subnet_name,"/[^0-9A-Za-z]/",""),0,11)}.ocivnet.oraclevcn.com"
}

resource "random_string" "suffix" {
  length  = var.random_suffix_length
  special = false
  upper   = false
}

# Azure Resource Group
module "azure-resource-grp" {
    source = "../../modules/azure-resource-grp"
    az_region=var.az_region
    resource_group_name = var.resource_group
    az_tags = local.az_tags
    new_rg = true
}

# AzureRM - Exadata Infrastructure
module "azurerm_exadata_infra" {
  source  = "../../modules/azurerm-ora-exadata-infra" 
  # depends_on = [ module.azure-resource-grp ]
  
  # Mandatory
  location                             = local.az_region
  name                                 = local.exadata_infrastructure_name
  resource_group_name                  = module.azure-resource-grp.resource_group_name
  zone                                 = local.az_zone
  compute_count                        = var.exadata_infrastructure_compute_count
  storage_count                        = var.exadata_infrastructure_storage_count

  # Optional
  shape                                = var.exadata_infrastructure_shape
  tags                                 = local.az_tags
  maintenance_window                   = var.exadata_infrastructure_maintenance_window

}

# Azure VNet with delegated subnet
module "avm_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  # depends_on = [ module.azure-resource-grp ]

  tags = local.az_tags
  resource_group_name = module.azure-resource-grp.resource_group_name
  location            = var.az_region
  name                = var.virtual_network_name
  address_space       = [var.virtual_network_address_space]

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

data "azurerm_subnet" "delegated_subnet" {
  name                 = var.delegated_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = module.azure-resource-grp.resource_group_name

  depends_on = [ module.avm_network ]
}

# Known Issue - https://docs.oracle.com/en-us/iaas/odexa/odexa-troubleshooting-and-known-issues-exadata-services.html
resource "time_sleep" "wait_after_deletion" {
  destroy_duration = var.destroy_duration
  depends_on = [module.azurerm_exadata_infra, module.oci-network-dns[0].oci_dns_view]
}

# AzureRM - Exadata VM Cluster
module "azurerm_exadata_vmc" {
  source  = "../../modules/azurerm-ora-exadata-vmc" 

  # VM Cluster details
  resource_group_name               = module.azure-resource-grp.resource_group_name
  location                        = local.az_region
  cloud_exadata_infrastructure_id = module.azurerm_exadata_infra.resource_id
  cloud_exadata_infrastructure_name = module.azurerm_exadata_infra.resource.name
  cluster_name                    = local.vm_cluster_name
  hostname                        = local.vm_cluster_hostname
  time_zone                       = var.vm_cluster_time_zone
  license_model                   = var.vm_cluster_license_model
  gi_version                      = var.vm_cluster_gi_version
  system_version                  = var.vm_cluster_system_version
  ssh_public_keys                 = var.vm_cluster_ssh_public_keys

  # Networking
  vnet_id                         = module.avm_network.resource_id
  subnet_id                       = data.azurerm_subnet.delegated_subnet.id
  backup_subnet_cidr              = var.vm_cluster_backup_subnet_cidr
  domain                          = var.vm_cluster_domain
  zone_id                         = local.oci_zone_id

  # VM Cluster allocation
  cpu_core_count                  = var.vm_cluster_cpu_core_count
  memory_size_in_gbs              = var.vm_cluster_memory_size_in_gbs
  dbnode_storage_size_in_gbs      = var.vm_cluster_db_node_storage_size_in_gbs

  # Exadata storage
  data_storage_size_in_tbs        = var.vm_cluster_data_storage_size_in_tbs
  data_storage_percentage         = var.vm_cluster_data_storage_percentage
  is_local_backup_enabled         = var.vm_cluster_is_local_backup_enabled
  is_sparse_diskgroup_enabled     = var.vm_cluster_is_sparse_diskgroup_enabled

  # Diagnostics Collection
  is_diagnostic_events_enabled    = var.vm_cluster_data_collection_options_is_diagnostics_events_enabled
  is_health_monitoring_enabled    = var.vm_cluster_data_collection_options_is_health_monitoring_enabled
  is_incident_logs_enabled        = var.vm_cluster_data_collection_options_is_incident_logs_enabled

  tags                            = local.az_tags
  depends_on = [time_sleep.wait_after_deletion]
  # depends_on = [module.azurerm_exadata_infra, module.avm_network, module.azure-resource-grp, module.oci-network-dns, time_sleep.wait_after_deletion]

}