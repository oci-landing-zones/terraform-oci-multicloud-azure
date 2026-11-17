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
  description = "Azure region with Oracle Database@Azure capacity, for example eastus."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "availability_zone" {
  description = "Azure logical availability zone supported for your subscription and database deployment."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.availability_zone))
    error_message = "availability_zone must be an Azure logical zone number, for example 1."
  }
}

variable "create_resource_group" {
  description = "Create a resource group; set false to use the existing resource_group_name."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the new or existing resource group for the anchors."
  type        = string
  default     = "rg-oradb-network"
  nullable    = false
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

variable "existing_resource_anchor_id" {
  description = "Reuse a Resource Anchor ARM ID; null creates one. It must match the subscription and resource group of the Network Anchor."
  type        = string
  default     = null
  validation {
    condition = var.existing_resource_anchor_id == null ? true : !var.create_resource_group && can(regex(
      "(?i)^/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", var.existing_resource_anchor_id
    ))
    error_message = "existing_resource_anchor_id requires create_resource_group = false and an anchor in the selected subscription and resource group."
  }
}

variable "create_network" {
  description = "Create a VNet and delegated subnet; set false and supply existing_subnet_id to reuse networking."
  type        = bool
  default     = true
  nullable    = false
}

variable "existing_subnet_id" {
  description = "Existing subnet ARM ID, required when create_network is false. Must already be delegated to Oracle.Database/networkAttachments."
  type        = string
  default     = null
  validation {
    condition = var.create_network ? var.existing_subnet_id == null : can(regex(
      "(?i)^/subscriptions/${var.subscription_id}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.existing_subnet_id
    ))
    error_message = "Set existing_subnet_id to a subnet ARM ID in this subscription when create_network is false; otherwise leave it null."
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
  default     = null
  validation {
    condition     = var.oci_backup_cidr_block == null ? true : can(cidrnetmask(var.oci_backup_cidr_block)) && can(regex("/(2[2-9]|3[0-2])$", var.oci_backup_cidr_block))
    error_message = "oci_backup_cidr_block must be null or a valid IPv4 CIDR of /22 or smaller address space."
  }
}

variable "oci_vcn_dns_label" {
  description = "OCI VCN DNS label. Set null only when supplying a DNS configuration supported by your database service."
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
  description = "Tags for resources created by this template."
  type        = map(string)
  default     = {}
  nullable    = false
}
