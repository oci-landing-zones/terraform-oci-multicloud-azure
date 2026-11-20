variable "resource_group_id" {
  description = "Azure resource group ARM ID that will own this resource."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "resource_group_id must be a valid ARM ID."
  }
}


variable "resource_anchor_id" {
  description = "Existing Resource Anchor ARM ID."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", var.resource_anchor_id))
    error_message = "resource_anchor_id must be a valid ARM ID."
  }
}


variable "network_anchor_id" {
  description = "Existing Network Anchor ARM ID."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/networkAnchors/[a-z0-9-]{3,24}$", var.network_anchor_id))
    error_message = "network_anchor_id must be a valid ARM ID."
  }
}


variable "cloud_exadata_infrastructure_id" {
  description = "Provisioned Exadata infrastructure ARM ID. Pass the infrastructure module id output to preserve creation ordering."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/cloudExadataInfrastructures/[^/]+$", var.cloud_exadata_infrastructure_id))
    error_message = "cloud_exadata_infrastructure_id must be a valid ARM ID."
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

variable "availability_zone" {
  description = "Azure logical zone matching the Network Anchor and infrastructure."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.availability_zone))
    error_message = "availability_zone must be a logical zone number."
  }
}

variable "name" {
  description = "Azure VM cluster resource name and OCI display name."
  type        = string
  default     = "oradb-vmcluster"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,254}$", var.name))
    error_message = "name must be 1-255 letters, digits, underscores or hyphens and start with a letter or digit."
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
  description = "Explicit DB server OCI OCIDs for VM placement (not Azure ARM IDs). Required unless discover_db_servers is explicitly enabled for newly created dedicated infrastructure."
  type        = list(string)
  default     = null
  validation {
    condition = var.db_servers == null ? var.discover_db_servers : (
      length(var.db_servers) >= 2 && length(distinct(var.db_servers)) == length(var.db_servers) &&
      alltrue([for id in var.db_servers : can(regex("^ocid1\\.dbserver\\.[a-zA-Z0-9._-]+$", id))])
    )
    error_message = "db_servers must contain at least two distinct DB server OCI OCIDs; explicit selection is required unless discover_db_servers is enabled."
  }
}

variable "db_server_count" {
  description = "Number of DB servers selected automatically when discover_db_servers is enabled; ignored when db_servers is supplied."
  type        = number
  default     = 2
  nullable    = false
  validation {
    condition     = var.db_server_count >= 2 && floor(var.db_server_count) == var.db_server_count
    error_message = "db_server_count must be an integer of at least two."
  }
}

variable "discover_db_servers" {
  description = "Explicitly allow automatic server selection for newly created dedicated infrastructure only. Keep false for shared or existing infrastructure."
  type        = bool
  nullable    = false
  default     = false
}


variable "tags" {
  description = "Tags for resources created by this module."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "network_ids" {
  description = "Optional known subnet/VNet ARM IDs for a Network Anchor created in the same root. They must match the anchor. Null reads IDs from the anchor; pass resource outputs instead of reconstructing IDs."
  type = object({
    subnet_id = string
    vnet_id   = string
  })
  default = null
  validation {
    condition = var.network_ids == null ? true : (
      can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.network_ids.subnet_id)) &&
      can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.network_ids.vnet_id))
    )
    error_message = "network_ids must contain valid subnet and VNet ARM IDs matching the selected Network Anchor."
  }
}
