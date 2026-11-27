provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

locals {
  avm_enable_telemetry        = var.avm_enable_telemetry
  az_tags                     = var.common_tags
  az_region                   = var.az_region
  az_zone                     = var.az_zone
  exadata_infrastructure_name = "${var.exadata_infrastructure_name}-${random_string.suffix.result}"
  vm_cluster_name             = "${var.vm_cluster_name}-${random_string.suffix.result}"
  vm_cluster_hostname         = "${var.vm_cluster_hostname}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = var.random_suffix_length
  special = false
  upper   = false
}

# # Generate SSH key for testing
# resource "tls_private_key" "vm_cluster_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_file" "private_key" {
#   filename        = "${path.module}/vm_cluster_private_key.pem"
#   content         = tls_private_key.vm_cluster_key.private_key_pem
#   file_permission = "0600"
# }

# Azure Resource Group
module "azure-resource-grp" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name             = var.resource_group
  location         = var.az_region
  tags             = local.az_tags
  enable_telemetry = local.avm_enable_telemetry
}

# AVM - Exadata Infrastructure
module "avm_exadata_infra" {
  # Terraform only
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.3.0"

  # OpenTofu or Terraform
  # source  = "github.com/Azure/terraform-azurerm-avm-res-oracledatabase-cloudexadatainfrastructure" 

  depends_on = [module.azure-resource-grp]

  # Mandatory
  location          = local.az_region
  name              = local.exadata_infrastructure_name
  display_name      = local.exadata_infrastructure_name
  resource_group_id = module.azure-resource-grp.resource_id
  zone              = var.az_zone
  compute_count     = var.exadata_infrastructure_compute_count
  storage_count     = var.exadata_infrastructure_storage_count

  # Optional
  shape                                = var.exadata_infrastructure_shape
  maintenance_window_leadtime_in_weeks = var.exadata_infrastructure_maintenance_window_lead_time_in_weeks
  maintenance_window_preference        = var.exadata_infrastructure_maintenance_window_preference
  maintenance_window_patching_mode     = var.exadata_infrastructure_maintenance_window_patching_mode

  tags             = local.az_tags
  enable_telemetry = local.avm_enable_telemetry

}

# Azure VNet with delegated subnet
module "avm_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.0"

  depends_on = [module.azure-resource-grp]

  tags          = local.az_tags
  parent_id     = module.azure-resource-grp.resource_id
  location      = var.az_region
  name          = var.virtual_network_name
  address_space = [var.virtual_network_address_space]
}

module "delegated_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.17.0"

  parent_id        = module.avm_network.resource_id
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

# Known Issue - https://docs.oracle.com/en-us/iaas/odexa/odexa-troubleshooting-and-known-issues-exadata-services.html
resource "time_sleep" "wait_after_deletion" {
  destroy_duration = "30m"
  depends_on       = [module.avm_exadata_infra]
}

# AVM - Exadata VM Cluster
module "avm_exadata_vmc" {
  # Terraform only
  source  = "Azure/avm-res-oracledatabase-cloudvmcluster/azurerm"
  version = "0.3.2"

  # OpenTofu or Terraform
  # source  = "github.com/Azure/terraform-azurerm-avm-res-oracledatabase-cloudvmcluster" 

  # VM Cluster details
  location                        = local.az_region
  cloud_exadata_infrastructure_id = module.avm_exadata_infra.resource_id
  cluster_name                    = local.vm_cluster_name
  hostname                        = local.vm_cluster_hostname
  time_zone                       = var.vm_cluster_time_zone
  license_model                   = var.vm_cluster_license_model
  gi_version                      = var.vm_cluster_gi_version
  ssh_public_keys                 = var.vm_cluster_ssh_public_keys

  # Networking
  vnet_id            = module.avm_network.resource_id
  subnet_id          = module.delegated_subnet.resource_id
  backup_subnet_cidr = var.vm_cluster_backup_subnet_cidr
  #domain             = var.delegated_subnet_name

  # VM Cluster allocation
  cpu_core_count             = var.vm_cluster_cpu_core_count
  memory_size_in_gbs         = var.vm_cluster_memory_size_in_gbs
  dbnode_storage_size_in_gbs = var.vm_cluster_db_node_storage_size_in_gbs

  # Exadata storage
  data_storage_size_in_tbs    = var.vm_cluster_data_storage_size_in_tbs
  data_storage_percentage     = var.vm_cluster_data_storage_percentage
  is_local_backup_enabled     = var.vm_cluster_is_local_backup_enabled
  is_sparse_diskgroup_enabled = var.vm_cluster_is_sparse_diskgroup_enabled

  # Diagnostics Collection
  is_diagnostic_events_enabled = var.vm_cluster_data_collection_options_is_diagnostics_events_enabled
  is_health_monitoring_enabled = var.vm_cluster_data_collection_options_is_health_monitoring_enabled
  is_incident_logs_enabled     = var.vm_cluster_data_collection_options_is_incident_logs_enabled

  resource_group_id = module.azure-resource-grp.resource_id
  tags              = local.az_tags
  enable_telemetry  = var.avm_enable_telemetry
  depends_on        = [module.avm_exadata_infra, module.avm_network, module.azure-resource-grp, time_sleep.wait_after_deletion]

}

