# https://github.com/hashicorp/terraform-provider-azurerm/releases
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.9.0"
    }
  }
}

data "azurerm_oracle_db_servers" "this" {
  resource_group_name               = var.resource_group_name
  cloud_exadata_infrastructure_name = var.cloud_exadata_infrastructure_name
}

resource "azurerm_oracle_cloud_vm_cluster" "this" {

    # VM Cluster details
    resource_group_name = var.resource_group_name
    location = var.location
    cloud_exadata_infrastructure_id = var.cloud_exadata_infrastructure_id
    cluster_name = var.cluster_name
    name = var.cluster_name
    display_name = var.cluster_name
    hostname = var.hostname 
    # hostname_actual = var.hostname_actual != null ? var.hostname_actual : null
    time_zone = var.time_zone
    license_model = var.license_model
    gi_version = var.gi_version
    system_version = var.system_version
    
    ssh_public_keys = var.ssh_public_keys
    db_servers = [for obj in data.azurerm_oracle_db_servers.this.db_servers : obj.ocid]

    # Networking
    virtual_network_id = var.vnet_id
    subnet_id = var.subnet_id
    backup_subnet_cidr = var.backup_subnet_cidr
    # pending on AzureRM 4.9.0 release
    # domain = var.domain != "" ? var.domain : null
    # zone_id = var.zone_id != "" ? var.zone_id : null

    # VM Cluster allocation
    cpu_core_count = var.cpu_core_count
    memory_size_in_gbs = var.memory_size_in_gbs
    db_node_storage_size_in_gbs = var.dbnode_storage_size_in_gbs

    # Exadata storage
    data_storage_size_in_tbs = var.data_storage_size_in_tbs
    data_storage_percentage= var.data_storage_percentage
    local_backup_enabled = var.is_local_backup_enabled
    sparse_diskgroup_enabled = var.is_sparse_diskgroup_enabled

    # Diagnostics Collection
    data_collection_options {
      diagnostics_events_enabled = var.is_diagnostic_events_enabled
      health_monitoring_enabled = var.is_health_monitoring_enabled
      incident_logs_enabled = var.is_incident_logs_enabled
    }

    tags = var.tags

    lifecycle {
        ignore_changes = [
          # For Idempotency
          id,
          cluster_name,
          hostname,
          subnet_id,
          backup_subnet_cidr,
          gi_version,
          system_version,

          # Updatable from OCI
          license_model,
          ssh_public_keys,
          db_servers, 
          cpu_core_count,
          memory_size_in_gbs,
          db_node_storage_size_in_gbs,
          data_storage_size_in_tbs,
        ]
    }
}

# Lookup OCID of VM Cluster for output
resource "time_sleep" "wait_10s" {
  create_duration = "10s"
  depends_on = [azurerm_oracle_cloud_vm_cluster.this]
}

data "azurerm_oracle_cloud_vm_cluster" "this" {
  depends_on = [ time_sleep.wait_10s ]
  name                = azurerm_oracle_cloud_vm_cluster.this.name
  resource_group_name = var.resource_group_name
}
