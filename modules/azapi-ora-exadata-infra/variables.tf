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
  description = "Existing Resource Anchor ARM ID in the infrastructure's resource group and subscription."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", var.resource_anchor_id)) && try(lower(join("/", slice(split("/", var.resource_anchor_id), 0, 5))) == lower(var.resource_group_id), false)
    error_message = "resource_anchor_id must be a valid ARM ID in the infrastructure's resource group and subscription."
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
  description = "Azure Exadata infrastructure resource name and OCI display name."
  type        = string
  default     = "oradb-infra"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,254}$", var.name))
    error_message = "name must be 1-255 letters, digits, underscores or hyphens and start with a letter or digit."
  }
}

variable "shape" {
  description = "Available Exadata dedicated hardware shape, for example Exadata.X9M."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.shape)) > 0
    error_message = "shape must not be empty."
  }
  validation {
    condition = !contains(["Exadata.X11M", "Exadata.X11MV"], var.shape) || (
      var.database_server_type != null && var.storage_server_type != null
    )
    error_message = "X11M-family shapes require database_server_type and storage_server_type from the target region's flexComponents metadata."
  }
}


variable "compute_count" {
  description = "Number of compute servers for new dedicated infrastructure."
  type        = number
  nullable    = false
  default     = 2
  validation {
    condition     = var.compute_count >= 2 && floor(var.compute_count) == var.compute_count
    error_message = "compute_count must be an integer of at least 2."
  }
}


variable "storage_count" {
  description = "Number of storage servers for new dedicated infrastructure."
  type        = number
  nullable    = false
  default     = 3
  validation {
    condition     = var.storage_count >= 3 && floor(var.storage_count) == var.storage_count
    error_message = "storage_count must be an integer of at least 3."
  }
}


variable "tags" {
  description = "Tags for resources created by this module."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "database_server_type" {
  description = "Database server type from the target region's flexComponents metadata. Required for X11M-family shapes; leave null for older shapes."
  type        = string
  default     = null
  validation {
    condition     = var.database_server_type == null ? true : length(trimspace(var.database_server_type)) > 0 && length(var.database_server_type) <= 255
    error_message = "database_server_type must be null or a nonempty string of at most 255 characters."
  }
}

variable "storage_server_type" {
  description = "Storage server type from the target region's flexComponents metadata. Required for X11M-family shapes; leave null for older shapes."
  type        = string
  default     = null
  validation {
    condition     = var.storage_server_type == null ? true : length(trimspace(var.storage_server_type)) > 0 && length(var.storage_server_type) <= 255
    error_message = "storage_server_type must be null or a nonempty string of at most 255 characters."
  }
}
