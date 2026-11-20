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
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", var.resource_anchor_id)) && try(lower(split("/", var.resource_anchor_id)[2]) == lower(split("/", var.resource_group_id)[2]) && lower(split("/", var.resource_anchor_id)[4]) == lower(split("/", var.resource_group_id)[4]), false)
    error_message = "resource_anchor_id must be a valid ARM ID in the selected resource group and subscription."
  }
}


variable "subnet_id" {
  description = "Existing subnet delegated to Oracle.Database/networkAttachments in the anchor's resource group and subscription."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id)) && try(lower(join("/", slice(split("/", var.subnet_id), 0, 5))) == lower(var.resource_group_id), false)
    error_message = "subnet_id must be a valid ARM ID in the anchor's resource group and subscription."
  }
}


variable "location" {
  description = "Azure region for the Network Anchor, matching its delegated subnet."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "availability_zone" {
  description = "Azure logical availability zone for the Network Anchor."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.availability_zone))
    error_message = "availability_zone must be a logical zone number."
  }
}

variable "name" {
  description = "Network Anchor name (3-24 letters, numbers or hyphens)."
  type        = string
  default     = "oradb-network-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "name must contain 3-24 letters, numbers or hyphens."
  }
}

variable "oci_backup_cidr_block" {
  description = "Optional private IPv4 backup CIDR, separate from Azure subnets and connected networks. /24 is recommended; maximum size is /22. Set for an Exadata deployment that requires backup networking."
  type        = string
  default     = null
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

variable "tags" {
  description = "Tags for resources created by this module."
  type        = map(string)
  default     = {}
  nullable    = false
}
