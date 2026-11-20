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
  description = "Azure region for the Network Anchor, Exadata infrastructure and VM cluster."
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

variable "create_resource_group" {
  description = "Create a resource group; set false to use the existing resource_group_name."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the new or existing Azure resource group for newly created anchors, networking and database infrastructure."
  type        = string
  default     = "rg-oradb-anchored"
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

variable "existing_resource_anchor" {
  description = "Optional existing Resource Anchor lookup. Reuse requires create_resource_group=false and the same resource_group_name for the entire deployment."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
  validation {
    condition = var.existing_resource_anchor == null ? true : (
      can(regex("^[a-zA-Z0-9-]{3,24}$", var.existing_resource_anchor.name)) &&
      can(regex("^[-\\p{L}\\p{N}_.()]{1,90}$", var.existing_resource_anchor.resource_group_name)) && !endswith(var.existing_resource_anchor.resource_group_name, ".")
    )
    error_message = "existing_resource_anchor must specify a valid 3-24 character anchor name and Azure resource group name."
  }
  validation {
    condition = var.existing_resource_anchor == null ? true : (
      !var.create_resource_group && lower(var.resource_group_name) == lower(var.existing_resource_anchor.resource_group_name)
    )
    error_message = "When reusing a Resource Anchor, set create_resource_group=false and use its resource group for the entire deployment."
  }
}

variable "existing_network_anchor" {
  description = "Optional existing Network Anchor lookup in the deployment resource group. Its Resource Anchor and network are discovered automatically; set create_resource_group=false."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
  validation {
    condition = var.existing_network_anchor == null ? true : (
      can(regex("^[a-zA-Z0-9-]{3,24}$", var.existing_network_anchor.name)) &&
      can(regex("^[-\\p{L}\\p{N}_.()]{1,90}$", var.existing_network_anchor.resource_group_name)) && !endswith(var.existing_network_anchor.resource_group_name, ".")
    )
    error_message = "existing_network_anchor must specify a valid 3-24 character anchor name and Azure resource group name."
  }
  validation {
    condition = var.existing_network_anchor == null ? true : (
      !var.create_resource_group && lower(var.resource_group_name) == lower(var.existing_network_anchor.resource_group_name)
    )
    error_message = "When reusing a Network Anchor, set create_resource_group=false and use its resource group for the entire deployment."
  }
}

variable "resource_anchor_name" {
  description = "Name used only when creating a Resource Anchor (3-24 letters, numbers or hyphens)."
  type        = string
  default     = "oradb-resource-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.resource_anchor_name))
    error_message = "resource_anchor_name must contain 3-24 letters, numbers or hyphens."
  }
}

variable "network_anchor_name" {
  description = "Network Anchor name (3-24 letters, numbers or hyphens)."
  type        = string
  default     = "oradb-network-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.network_anchor_name))
    error_message = "network_anchor_name must contain 3-24 letters, numbers or hyphens."
  }
}

variable "virtual_network_name" {
  description = "Name of the VNet to create."
  type        = string
  default     = "vnet-oradb"
  nullable    = false
}

variable "virtual_network_address_space" {
  description = "Private IPv4 CIDRs for the new VNet. Choose ranges that do not overlap your connected networks."
  type        = list(string)
  default     = ["10.20.0.0/16"]
  nullable    = false
  validation {
    condition     = length(var.virtual_network_address_space) > 0 && alltrue([for cidr in var.virtual_network_address_space : can(cidrnetmask(cidr))])
    error_message = "virtual_network_address_space must contain valid IPv4 CIDRs."
  }
}

variable "delegated_subnet_name" {
  description = "Name of the delegated subnet to create."
  type        = string
  default     = "snet-oradb"
  nullable    = false
}

variable "delegated_subnet_address_prefix" {
  description = "Private IPv4 CIDR inside the new VNet; supported client subnet sizes are /22 through /27."
  type        = string
  default     = "10.20.1.0/24"
  nullable    = false
  validation {
    condition     = can(cidrnetmask(var.delegated_subnet_address_prefix)) && can(regex("/(22|23|24|25|26|27)$", var.delegated_subnet_address_prefix))
    error_message = "delegated_subnet_address_prefix must be an IPv4 CIDR between /22 and /27."
  }
}

variable "oci_backup_cidr_block" {
  description = "Optional private IPv4 backup CIDR, separate from Azure subnets and connected networks. /24 is recommended; maximum size is /22. Set for an Exadata deployment that requires backup networking."
  type        = string
  default     = "192.168.252.0/24"
  validation {
    condition     = var.oci_backup_cidr_block == null ? true : can(cidrnetmask(var.oci_backup_cidr_block)) && can(regex("/(2[2-9]|3[0-2])$", var.oci_backup_cidr_block))
    error_message = "oci_backup_cidr_block must be null or a valid IPv4 CIDR of /22 or smaller address space."
  }
}

variable "oci_vcn_dns_label" {
  description = "Requested create-time OCI VCN DNS label; the service can return a canonical VNet-derived label. Set null only when supplying a DNS configuration supported by your database service."
  type        = string
  default     = "oradb"
  validation {
    condition     = var.oci_vcn_dns_label == null ? true : can(regex("^[a-zA-Z][a-zA-Z0-9]{0,14}$", var.oci_vcn_dns_label))
    error_message = "oci_vcn_dns_label must start with a letter and contain 1-15 alphanumeric characters."
  }
}

variable "dns" {
  description = "Optional Network Anchor DNS settings. Null flags preserve service defaults. Domain names and listening CIDRs are serialized as comma-separated API strings. Customer DNS resolvers/rules are managed separately."
  type = object({
    zone_sync_enabled                = optional(bool)
    listening_endpoint_enabled       = optional(bool)
    forwarding_endpoint_enabled      = optional(bool)
    listening_endpoint_allowed_cidrs = optional(list(string), [])
    forwarding_rules = optional(list(object({
      domain_names          = list(string)
      forwarding_ip_address = string
    })), [])
  })
  default  = {}
  nullable = false
  validation {
    condition     = alltrue([for cidr in var.dns.listening_endpoint_allowed_cidrs : can(cidrnetmask(cidr))])
    error_message = "DNS listening endpoint allowed CIDRs must be valid IPv4 CIDRs."
  }
  validation {
    condition = alltrue([for rule in var.dns.forwarding_rules :
      length(rule.domain_names) > 0 && alltrue([for domain in rule.domain_names : length(trimspace(domain)) > 0 && length(regexall(",", domain)) == 0]) && can(cidrnetmask("${rule.forwarding_ip_address}/32"))
    ])
    error_message = "Each forwarding rule needs nonempty domain names without commas and a valid IPv4 forwarding address."
  }
  validation {
    condition     = length(var.dns.listening_endpoint_allowed_cidrs) == 0 || var.dns.listening_endpoint_enabled == true
    error_message = "Enable the listening endpoint when supplying allowed CIDRs."
  }
  validation {
    condition     = length(var.dns.forwarding_rules) == 0 || var.dns.forwarding_endpoint_enabled == true
    error_message = "Enable the forwarding endpoint when supplying forwarding rules."
  }
}

variable "existing_subnet_id" {
  description = "Optional existing Oracle-delegated subnet for a new Network Anchor. Null creates a VNet/subnet; leave null when reusing a Network Anchor."
  type        = string
  default     = null
  validation {
    condition = var.existing_subnet_id == null ? true : (
      var.existing_network_anchor == null &&
      can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.existing_subnet_id)) &&
      try(lower(split("/", var.existing_subnet_id)[2]) == lower(var.subscription_id) && lower(split("/", var.existing_subnet_id)[4]) == lower(var.resource_group_name), false)
    )
    error_message = "existing_subnet_id must identify a delegated subnet in the deployment resource group and subscription and is only valid when creating a new Network Anchor."
  }
}

variable "infrastructure" {
  description = "New Exadata dedicated infrastructure name, shape and server counts. Confirm capacity and shape availability with Oracle."
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
  description = "Explicit DB server OCI OCIDs for VM placement (not Azure ARM IDs). Null discovers servers after the new infrastructure is created. Pin the discovered IDs before any infrastructure edit, including tags."
  type        = list(string)
  default     = null
  validation {
    condition = var.db_servers == null ? true : (
      length(var.db_servers) >= 2 && length(distinct(var.db_servers)) == length(var.db_servers) &&
      alltrue([for id in var.db_servers : can(regex("^ocid1\\.dbserver\\.[a-zA-Z0-9._-]+$", id))])
    )
    error_message = "db_servers must contain at least two distinct DB server OCI OCIDs."
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
