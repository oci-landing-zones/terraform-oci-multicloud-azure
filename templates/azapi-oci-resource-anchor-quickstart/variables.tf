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
  description = "Azure region for the optional new resource group, for example eastus. The Resource Anchor always uses the global ARM location."
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
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the new or existing Azure resource group mapped to an OCI compartment."
  type        = string
  default     = "rg-oradb-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[-\\p{L}\\p{N}_.()]{1,90}$", var.resource_group_name)) && !endswith(var.resource_group_name, ".")
    error_message = "resource_group_name must be 1-90 letters, numbers, hyphens, underscores, periods or parentheses, and must not end with a period."
  }
}

variable "resource_anchor_name" {
  description = "Resource Anchor name (3-24 letters, numbers or hyphens)."
  type        = string
  default     = "oradb-resource-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.resource_anchor_name))
    error_message = "resource_anchor_name must contain 3-24 letters, numbers or hyphens."
  }
}

variable "tags" {
  description = "Tags for resources created by this template."
  type        = map(string)
  default     = {}
  nullable    = false
}
