
variable "region" {
  type        = string
  description = "OCI region name. e.g. uk-south-1"
}

variable "location" {
  description = "The location of the resources on Azure. e.g. useast"
  type        = string
}


# Networking Resources
variable "resource_group_name" {
  type        = string
  description = "The name of resource group on Azure."
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "virtual_network_address_space" {
  description = "The address space of the virtual network. e.g. 10.2.0.0/16"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.virtual_network_address_space))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "delegated_subnet_name" {
  description = "The name of the delegated subnet"
  type        = string
}

variable "delegated_subnet_address_prefix" {
  description = "The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.delegated_subnet_address_prefix))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

#

variable "db_home_display_name" {
  type        = string
  description = "The display name of the DB Home"
}

variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -."
}

variable "db_name" {
  type        = string
  description = "The database name. The name must begin with an alphabetic character and can contain a maximum of eight alphanumeric characters. Special characters are not permitted."
}

variable "pdb_name" {
  type        = string
  description = "The name of the pluggable database. The name must begin with an alphabetic character and can contain a maximum of thirty alphanumeric characters. Special characters are not permitted. Pluggable database should not be same as database name."
}

# Merging exadata_infrastructure_resource_name and exadata_infrastructure_resource_display_name as they have to be identical
variable "exadata_infrastructure_name" {
  description = "The name of the Exadata Infrastructure."
  type        = string
}

# variable "exadata_infrastructure_resource_name" {
#   description = "The name of the Exadata Infrastructure on Azure."
#   type        = string
# }

# variable "exadata_infrastructure_resource_display_name" {
#   description = "The display name of the Exadata Infrastructure on OCI."
#   type        = string
# }

variable "zones" {
  description = "The zone of the Exadata Infrastructure for Azure."
  type        = string
}

variable "vm_cluster_resource_name" {
  description = "The resource name of a VM Cluster on Azure."
  type        = string
}

variable "vm_cluster_display_name" {
  description = "The display name of a VM Cluster on OCI."
  type        = string
}

variable "vm_cluster_ssh_public_key" {
  description = "The public SSH key for VM Cluster."
  type        = string
}

variable "db_home_source" {
  type        = string
  description = "The source of database. For Exadata VM Cluster, use VM_CLUSTER_NEW"
}

variable "db_version" {
  type        = string
  description = "A valid Oracle Database version. e.g. 19.20.0.0"
}

variable "db_source" {
  type        = string
  description = "The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup. "
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
  description = "The hostname for the cloud VM Cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems."
  type        = string
}

variable "vm_cluster_license_model" {
  description = "The Oracle license model that applies to the VM cluster. Allowed values are: LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE"
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

variable "exadata_infrastructure_compute_cpu_count" {
  description = "The number of compute servers for the cloud Exadata infrastructure."
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

variable "exadata_infrastructure_storage_count" {
  description = "The number of storage servers for the Exadata infrastructure."
  type        = number
}




variable "config_file_profile" {
  type        = string
  default     = "DEFAULT"
  description = "OCI Config file name"
}

variable "nsg_cidrs" {
  type = list(object({
    source               = string,
    destinationPortRange = map(string)
  }))
  description = "Add additional Network ingress rules for the VM cluster's network security group. e.g. If connect to the VM Cluster from a different Azure VNET where the VM Cluster is located in, please set this to [{source: \"0.0.0.0/0\",destinationPortRange:{max:1522,min:1521}}]"
  default     = []
}

variable "vm_network_resource_group_name" {
  type        = string
  description = "The resource group name of virtual machine network on Azure."
  default     = ""
}

variable "vm_size" {
  description = "The SKU which should be used for this Virtual Machine, such as Standard_D2s_v3 or Standard_D2as_v4."
  type        = string
}

variable "vm_subnet_address_prefix" {
  description = "The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.0.0/24"
  type        = string
  validation {
    condition     = var.vm_subnet_address_prefix == "" || can(cidrnetmask(var.vm_subnet_address_prefix))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
  default = ""
}

variable "vm_virtual_network_address_space" {
  description = "The address space of the VM's virtual network. e.g. 10.2.0.0/16."
  type        = string
  validation {
    condition     = var.vm_virtual_network_address_space == "" || can(cidrnetmask(var.vm_virtual_network_address_space))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
  default = ""
}

variable "vm_vnet_name" {
  description = "The virtual network name of the virtual machine."
  type        = string
  default     = ""
}

variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  type        = string
  default     = ""
}

variable "ssh_private_key_file" {
  type        = string
  description = "The file path to SSH private key use to connect to VM."
  sensitive   = true
  validation {
    condition     = var.ssh_private_key_file == "" || can(file(var.ssh_private_key_file))
    error_message = "Must be a valid file path"
  }
  default = ""
}

variable "vm_public_ip_address" {
  type        = string
  description = "The public IP address of the Virtual machine."
  default     = ""
}

variable "enable_connectivity_validation" {
  type        = bool
  description = "Enable or disable the CDB/PDB connectivity test."
  default     = true
}