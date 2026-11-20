variable "resource_group_id" {
  description = "Azure resource group ARM ID that will own this resource."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "resource_group_id must be a valid ARM ID."
  }
}

variable "name" {
  description = "Resource Anchor name (3-24 letters, numbers or hyphens)."
  type        = string
  default     = "oradb-resource-anchor"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "name must contain 3-24 letters, numbers or hyphens."
  }
}

variable "tags" {
  description = "Tags for resources created by this module."
  type        = map(string)
  default     = {}
  nullable    = false
}
