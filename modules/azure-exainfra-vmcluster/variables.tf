# -----------------------------------------------------------------------------
# Required inputs
# -----------------------------------------------------------------------------
variable "location" {
  description = "The location of the exadata infrastructure."
  type        = string
}

variable "zones" {
  description = "The zone of the exadata infrastructure."
  type        = string
}

variable "resource_group_id" {
  type        = string
  description = "The Azure Id of resource group"
}

# Merging exadata_infrastructure_resource_name and exadata_infrastructure_resource_display_name as they have to be identical
variable "exadata_infrastructure_name" {
  description = "The name of the exadata infrastructure."
  type        = string
}

# variable "exadata_infrastructure_resource_name" {
#   description = "The name of the exadata infrastructure on Azure."
#   type        = string
# }
# variable "exadata_infrastructure_resource_display_name" {
#   description = "The display name of the exadata infrastructure."
#   type        = string
# }

variable "exadata_infrastructure_compute_cpu_count" {
  description = "The number of compute servers for the cloud Exadata infrastructure."
  type        = number
}

variable "exadata_infrastructure_storage_count" {
  description = "The number of storage servers for the Exadata infrastructure."
  type        = number
}

variable "exadata_infrastructure_shape" {
  description = "The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M"
  type        = string
}

variable "exadata_infrastructure_maintenance_window_lead_time_in_weeks" {
  description = "Lead time window allows user to set a lead time to prepare for a down time. The lead time is in weeks and valid value is between 1 to 4."
  type        = number
}

variable "exadata_infrastructure_maintenance_window_preference" {
  description = "The maintenance window scheduling preference.Allowed values are: NO_PREFERENCE, CUSTOM_PREFERENCE."
  type        = string
}

variable "exadata_infrastructure_maintenance_window_patching_mode" {
  description = "Cloud Exadata infrastructure node patching method, either ROLLING or NONROLLING."
  type        = string
}

variable "vnet_id" {
  description = "The Azure id of the virtual network"
  type        = string
}
variable "oracle_database_delegated_subnet_id" {
  description = "Azure Id of the delegated subnet"
  type        = string
}


variable "vm_cluster_resource_name" {
  description = "The resource name of a VM cluster"
  type        = string
}

variable "vm_cluster_display_name" {
  description = "The display name of a VM cluster"
  type        = string
}

variable "vm_cluster_cpu_core_count" {
  description = "The number of CPU cores to enable for the VM cluster."
  type        = number
}

variable "vm_cluster_data_collection_options_is_diagnostics_events_enabled" {
  description = "Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. "
  type        = bool
}
variable "vm_cluster_data_collection_options_is_health_monitoring_enabled" {
  description = "Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. "
  type        = bool
}
variable "vm_cluster_data_collection_options_is_incident_logs_enabled" {
  description = "Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. "
  type        = bool
}

variable "vm_cluster_data_storage_percentage" {
  description = "The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. "
  type        = number
}

variable "vm_cluster_data_storage_size_in_tbs" {
  description = "The data disk group size to be allocated in TBs."
  type        = number
}

variable "vm_cluster_db_node_storage_size_in_gbs" {
  description = "The local node storage to be allocated in GBs."
  type        = number
}

variable "vm_cluster_gi_version" {
  description = "The Oracle Grid Infrastructure software version for the VM cluster."
  type        = string
}

variable "vm_cluster_hostname" {
  description = "The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems."
  type        = string
}

variable "vm_cluster_license_model" {
  description = "The Oracle license model that applies to the VM clusterAllowed values are: LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE"
  type        = string
}

variable "vm_cluster_memory_size_in_gbs" {
  description = "The memory to be allocated in GBs."
  type        = number
}

variable "vm_cluster_time_zone" {
  description = "The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html"
  type        = string
}

variable "vm_cluster_is_local_backup_enabled" {
  description = "If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster."
  type        = bool
}

variable "vm_cluster_is_sparse_diskgroup_enabled" {
  description = "If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created."
  type        = bool
}


variable "vm_cluster_ssh_public_key" {
  description = "The public SSH key for VM cluster."
  type        = string
}

variable "nsg_cidrs" {
  type = list(object({
    source = string,
    destinationPortRange = object({
      min = number
      max = number
    })
  }))
  default     = []
  description = "Add additional Network ingress rules for the VM cluster's network security group. e.g. [{'source': '0.0.0.0/0','destinationPortRange': {'max': 1522,'min': 1521 }}]."
}
