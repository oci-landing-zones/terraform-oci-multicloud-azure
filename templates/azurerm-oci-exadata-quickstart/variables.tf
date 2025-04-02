# Common

## Resource Tags
variable "common_tags" {
  description = "resource tags to be used in both Azure and OCI"
  type        = map(string)
  default = {
    createdby = "azurerm-oci-exadata-quickstart"
  }
}

## Mandatory to randomise namaing for resource group, exadata infra and vmcluster
variable "random_suffix_length" {
  type = number
  default = 3
}

# Azure Verified Module (AVM)
variable "avm_enable_telemetry" {
  description = "This variable controls whether or not telemetry is enabled for the Azure Verified Modules"
  type        = bool
  default = true
}

# Azure Resource Group (azure-resource-grp)
variable "az_region" {
  description = "The location of the resources on Azure. e.g. useast"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "Resource Group Name"
  default = "rg-oradb"
}

variable "new_rg" {
  type        = bool
  description = "Create new resource group or not"
  default     = true
}

# Exadata Infrastructure (azure-exainfra)
variable "az_zone" {
  description = "The zone of the exadata infrastructure"
  type        = string
}

variable "exadata_infrastructure_name" {
  description = "The name of the exadata infrastructure on Azure"
  type        = string
  default     = "odaaz-infra"
}

variable "exadata_infrastructure_compute_count" {
  description = "The number of compute servers for the cloud Exadata infrastructure."
  type        = number
  default = 2
}

variable "exadata_infrastructure_storage_count" {
  description = "The number of storage servers for the Exadata infrastructure."
  type        = number
  default = 3
}

variable "exadata_infrastructure_shape" {
  description = "The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M"
  type        = string
  default = "Exadata.X9M"
}

# variable "exadata_infrastructure_maintenance_window_lead_time_in_weeks" {
#   description = "Lead time window allows user to set a lead time to prepare for a down time. The lead time is in weeks and valid value is between 1 to 4."
#   type        = number
#   default = 1
# }

# variable "exadata_infrastructure_maintenance_window_preference" {
#   description = "The maintenance window scheduling preference.Allowed values are: NO_PREFERENCE, CUSTOM_PREFERENCE."
#   type        = string
#   default = "NO_PREFERENCE"
# }

# variable "exadata_infrastructure_maintenance_window_patching_mode" {
#   description = "Cloud Exadata infrastructure node patching method, either ROLLING or NONROLLING."
#   type        = string
#   default = "ROLLING"
# }

variable "exadata_infrastructure_maintenance_window" {
  description = "maintenanceWindow properties"
  type = object({
      patching_mode = string
      preference = string
      lead_time_in_weeks = optional(number)
      months = optional(list(number))
      weeks_of_month = optional(list(number))
      days_of_week =optional(list(number))
      hours_of_day = optional(list(number))
  })
  default = {
    patching_mode = "Rolling"
    preference = "NoPreference"
  }
}

# Azure VNet
variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-oci"
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
  default     = "snet-delegate-oci"
}

variable "delegated_subnet_address_prefix" {
  description = "The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.delegated_subnet_address_prefix))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

# VM Cluster
variable "vm_cluster_name" {
  description = "The name of a VM cluster"
  type        = string
}

variable "vm_cluster_gi_version" {
  description = "The Oracle Grid Infrastructure software version for the VM cluster."
  type        = string
  default     = "19.0.0.0"
}

variable "vm_cluster_system_version" {
  description = "Operating system version of the Exadata image."
  type        = string
  default     = null
}

variable "vm_cluster_hostname" {
  description = "The prefix forms the first portion of the Exadata VM Cluster host name. Recommended maximum: 12 characters."
  type        = string
}

variable "vm_cluster_cpu_core_count" {
  description = "The number of CPU cores to enable for the VM cluster."
  type        = number
  default     = 4
}

# variable "vm_cluster_ocpu_count" {
#   description = "The number of OCPU cores to enable on the cloud VM cluster."
#   type        = number
# }

variable "vm_cluster_data_collection_options_is_diagnostics_events_enabled" {
  description = "Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. "
  type        = bool
  default     = true
}
variable "vm_cluster_data_collection_options_is_health_monitoring_enabled" {
  description = "Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. "
  type        = bool
  default     = true
}
variable "vm_cluster_data_collection_options_is_incident_logs_enabled" {
  description = "Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. "
  type        = bool
  default     = true
}

variable "vm_cluster_data_storage_percentage" {
  description = "The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. "
  type        = number
  default     = 80
}

variable "vm_cluster_data_storage_size_in_tbs" {
  description = "The data disk group size to be allocated in TBs."
  type        = number
  default     = 2
}

variable "vm_cluster_db_node_storage_size_in_gbs" {
  description = "The local node storage to be allocated in GBs."
  type        = number
  default     = 500
}

variable "vm_cluster_license_model" {
  description = "The Oracle license model that applies to the VM clusterAllowed values are: LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE"
  type        = string
  default     = "LicenseIncluded"
}

variable "vm_cluster_memory_size_in_gbs" {
  description = "The memory to be allocated in GBs."
  type        = number
  default     = 60
}

variable "vm_cluster_time_zone" {
  description = "The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html"
  type        = string
  default     = "UTC"
}

variable "vm_cluster_is_local_backup_enabled" {
  description = "If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster."
  type        = bool
  default     = false
}

variable "vm_cluster_is_sparse_diskgroup_enabled" {
  description = "If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created."
  type        = bool
  default     = false
}

variable "vm_cluster_ssh_public_keys" {
  description = "The public SSH keys for VM cluster."
  type        = list(string)
}

variable "vm_cluster_backup_subnet_cidr" {
  description = "OCI backup subnet CIDR"
  type        = string
  default = "192.168.252.0/22"
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

variable "vm_cluster_domain" {
  description = "The domain name for the cloud VM cluster."
  type = string
  default=""
}

variable "vm_cluster_scan_listener_port_tcp" {
  description = "The TCP Single Client Access Name (SCAN) port. The default port is 1521."
  type = number
  default = 1521
}

variable "vm_cluster_scan_listener_port_tcp_ssl" {
  description = "The TCPS Single Client Access Name (SCAN) port. The default port is 2484."
  type = number
  default = 2484
}

# OCI Authentication
variable "oci_config_file_profile" {
  type        = string
  default     = "DEFAULT"
  description = "OCI Config file name"
}

variable oci_tenancy_ocid {
  type        = string
  description = "OCID of the OCI tenancy"
}
variable oci_user_ocid {
  type        = string
  description = "OCID of the OCI user"

}
variable oci_private_key_path {
  type        = string
  description = "The path (including filename) of the private key"

}
variable oci_private_key_password {
  type        = string
  description = "Passphrase used for the key, if it's encrypted"
  sensitive   = true
  default = null
}

variable oci_fingerprint {
  type        = string
  description = "Fingerprint for the key pair being used"
}

# Oracle Database Home
variable "db_home_source" {
  type        = string
  description = "The source of database. For Exadata VM Cluster, use VM_CLUSTER_NEW"
  default     = "VM_CLUSTER_NEW"
}

variable "db_home_version" {
  type        = string
  description = "A valid Oracle Database version. e.g. 19.0.0.0"
  default     = "19.0.0.0"
}

variable "db_home_name" {
  type        = string
  description = "The name of the DB Home"
  default     = "dbhome"
}

variable "enable_database_delete" {
  type = bool
  default = false
  description = "Unless enable_database_delete is explicitly set to true, Terraform will not delete the database within the Db Home configuration but rather remove it from the config and state file."
}

# Oracle Container Database
variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "db_admin_password" {
  type        = string
  description = "A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -."
  sensitive   = true
}

variable "db_source" {
  type        = string
  description = "The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup. "
  default     = "NONE"
}

# OCI Networking
variable "vm_cluster_new_oci_dns" {
  description = "Create private DNS zone in OCI when custom domain is configured. Set to false for reusing existing DNS zone"
  type = bool
  default = true
}

# wait time before destory
variable "destroy_duration" {
  type = string
  default = "30m"
}