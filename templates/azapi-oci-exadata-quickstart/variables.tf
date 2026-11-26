variable "subscription_id" {
  description = "Azure subscription ID with Oracle Database@Azure onboarding completed."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a UUID."
  }
}

variable "location" {
  description = "Azure region matching the existing Network Anchor and Exadata capacity."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "create_resource_group" {
  description = "Create a resource group; set false to use the existing resource_group_name."
  type        = bool
  default     = false
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the new or existing Azure resource group for the infrastructure and VM cluster."
  type        = string
  default     = "rg-oradb-workload"
  nullable    = false
  validation {
    condition     = can(regex("^[-\\p{L}\\p{N}_.()]{1,90}$", var.resource_group_name)) && !endswith(var.resource_group_name, ".")
    error_message = "resource_group_name must be 1-90 letters, numbers, hyphens, underscores, periods or parentheses, and must not end with a period."
  }
}

variable "tags" {
  description = "Tags for resources created by this template."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "availability_zone" {
  description = "Azure logical zone matching the Network Anchor and infrastructure."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.availability_zone))
    error_message = "availability_zone must be a logical zone number."
  }
}

variable "resource_anchor_id" {
  description = "Existing Oracle.Database/resourceAnchors Azure ARM ID, from the companion anchor quickstarts."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", var.resource_anchor_id)) && try(lower(split("/", var.resource_anchor_id)[2]) == lower(var.subscription_id), false)
    error_message = "resource_anchor_id must be a resourceAnchors ARM ID in the selected subscription."
  }
}

variable "network_anchor_id" {
  description = "Existing Oracle.Database/networkAnchors Azure ARM ID, from the companion anchor quickstarts."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/networkAnchors/[a-z0-9-]{3,24}$", var.network_anchor_id)) && try(lower(split("/", var.network_anchor_id)[2]) == lower(var.subscription_id), false)
    error_message = "network_anchor_id must be a networkAnchors ARM ID in the selected subscription."
  }
}

variable "existing_cloud_exadata_infrastructure_id" {
  description = "Optional existing Exadata infrastructure ARM ID. Null creates capacity; a supplied ID creates only the VM cluster."
  type        = string
  default     = null
  validation {
    condition     = var.existing_cloud_exadata_infrastructure_id == null ? true : can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/cloudExadataInfrastructures/[^/]+$", var.existing_cloud_exadata_infrastructure_id)) && try(lower(split("/", var.existing_cloud_exadata_infrastructure_id)[2]) == lower(var.subscription_id), false)
    error_message = "Existing infrastructure must be an ARM ID in the selected subscription."
  }
}

variable "infrastructure" {
  description = "New Exadata dedicated infrastructure settings; ignored when reusing existing infrastructure. Confirm shape and capacity availability with Oracle."
  type = object({
    name                 = string
    shape                = string
    compute_count        = optional(number, 2)
    storage_count        = optional(number, 3)
    database_server_type = optional(string)
    storage_server_type  = optional(string)
  })
  default  = { name = "oradb-infra", shape = "Exadata.X9M" }
  nullable = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,254}$", var.infrastructure.name)) && length(trimspace(var.infrastructure.shape)) > 0 && var.infrastructure.compute_count >= 2 && floor(var.infrastructure.compute_count) == var.infrastructure.compute_count && var.infrastructure.storage_count >= 3 && floor(var.infrastructure.storage_count) == var.infrastructure.storage_count
    error_message = "Infrastructure needs a valid name and shape, at least 2 compute servers and 3 storage servers, with integer counts."
  }
}

variable "vm_cluster_name" {
  description = "Azure VM cluster resource name and OCI display name."
  type        = string
  default     = "oradb-vmcluster"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,254}$", var.vm_cluster_name))
    error_message = "vm_cluster_name must be 1-255 letters, digits, underscores or hyphens and start with a letter or digit."
  }
}

variable "hostname" {
  description = "VM cluster hostname prefix; use a short unique prefix to leave room for service-generated suffixes."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z]([a-zA-Z0-9-]{0,21}[a-zA-Z0-9])?$", var.hostname)) && lower(var.hostname) != "localhost"
    error_message = "hostname must be 1-23 letters, numbers or hyphens, start with a letter, end with an alphanumeric character and not be localhost."
  }
}

variable "gi_version" {
  description = "Oracle Grid Infrastructure version available for the region/shape, such as 19.0.0.0. Do not assume the example is currently available."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+){3,4}$", var.gi_version))
    error_message = "gi_version must be a numeric dotted Grid Infrastructure version."
  }
}

variable "ssh_public_keys" {
  description = "RSA SSH public keys for cluster access. Supply public keys only, never private key material."
  type        = list(string)
  nullable    = false
  validation {
    condition     = length(var.ssh_public_keys) > 0 && alltrue([for key in var.ssh_public_keys : can(regex("^ssh-rsa [A-Za-z0-9+/]+={0,3}( .*)?$", trimspace(key)))])
    error_message = "ssh_public_keys must contain single-line RSA OpenSSH public keys (not private keys or paths)."
  }
}

variable "cpu_core_count" {
  description = "CPU cores allocated to the VM cluster. Confirm shape-specific minimum, increment and available capacity."
  type        = number
  nullable    = false
  validation {
    condition     = var.cpu_core_count > 0 && floor(var.cpu_core_count) == var.cpu_core_count
    error_message = "cpu_core_count must be a positive integer."
  }
}

variable "memory_size_in_gbs" {
  description = "Total VM cluster memory allocation in GB across selected DB servers; confirm capacity, divisibility and per-VM sizing."
  type        = number
  nullable    = false
  default     = 256
  validation {
    condition     = var.memory_size_in_gbs > 0 && floor(var.memory_size_in_gbs) == var.memory_size_in_gbs
    error_message = "memory_size_in_gbs must be a positive integer number of GB."
  }
}

variable "db_node_storage_size_in_gbs" {
  description = "Total local DB node storage allocation in GB across selected DB servers; confirm capacity and supported increments."
  type        = number
  nullable    = false
  default     = 256
  validation {
    condition     = var.db_node_storage_size_in_gbs > 0 && floor(var.db_node_storage_size_in_gbs) == var.db_node_storage_size_in_gbs
    error_message = "db_node_storage_size_in_gbs must be a positive integer number of GB."
  }
}

variable "data_storage_size_in_tbs" {
  description = "DATA disk group allocation in TB; confirm supported minimum and increments."
  type        = number
  nullable    = false
  default     = 2
  validation {
    condition     = var.data_storage_size_in_tbs > 0
    error_message = "data_storage_size_in_tbs must be greater than zero TB."
  }
}

variable "data_storage_percentage" {
  description = "DATA storage percentage; remaining space is RECO."
  type        = number
  nullable    = false
  default     = 80
  validation {
    condition     = contains([35, 40, 60, 80], var.data_storage_percentage)
    error_message = "data_storage_percentage must be 35, 40, 60 or 80."
  }
}

variable "license_model" {
  description = "Oracle licensing model using Azure API enum values."
  type        = string
  default     = "BringYourOwnLicense"
  nullable    = false
  validation {
    condition     = contains(["LicenseIncluded", "BringYourOwnLicense"], var.license_model)
    error_message = "license_model must be LicenseIncluded or BringYourOwnLicense."
  }
}

variable "time_zone" {
  description = "Oracle-supported time zone for the VM cluster."
  type        = string
  default     = "UTC"
  nullable    = false
  validation {
    condition     = length(trimspace(var.time_zone)) > 0
    error_message = "time_zone must not be empty."
  }
}

variable "is_local_backup_enabled" {
  description = "Enable local Exadata backups."
  type        = bool
  default     = false
  nullable    = false
}

variable "is_sparse_diskgroup_enabled" {
  description = "Enable the SPARSE disk group."
  type        = bool
  default     = false
  nullable    = false
}

variable "data_collection_options" {
  description = "Oracle diagnostic collection preferences."
  type = object({
    diagnostics_events_enabled = optional(bool, false)
    health_monitoring_enabled  = optional(bool, false)
    incident_logs_enabled      = optional(bool, false)
  })
  default  = {}
  nullable = false
}

variable "db_servers" {
  description = "Explicit DB server OCI OCIDs for VM placement (not Azure ARM IDs). Required when reusing infrastructure. Null discovers servers only for new dedicated infrastructure."
  type        = list(string)
  default     = null
  validation {
    condition = var.db_servers == null ? var.existing_cloud_exadata_infrastructure_id == null : (
      length(var.db_servers) >= 2 && length(distinct(var.db_servers)) == length(var.db_servers) &&
      alltrue([for id in var.db_servers : can(regex("^ocid1\\.dbserver\\.[a-zA-Z0-9._-]+$", id))])
    )
    error_message = "db_servers must contain at least two distinct DB server OCI OCIDs; explicit selection is required for existing infrastructure."
  }
}

variable "db_server_count" {
  description = "Number of DB servers selected automatically for new infrastructure; ignored when db_servers is supplied."
  type        = number
  default     = 2
  nullable    = false
  validation {
    condition     = var.db_server_count >= 2 && floor(var.db_server_count) == var.db_server_count && (var.db_servers != null || var.db_server_count <= var.infrastructure.compute_count)
    error_message = "db_server_count must be an integer of at least two and cannot exceed the new infrastructure compute_count when selecting automatically."
  }
}
