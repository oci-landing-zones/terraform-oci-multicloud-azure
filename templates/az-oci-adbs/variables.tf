variable "location" {
  type        = string
  description = "Resource region"
}
variable "resource_group" {
  type        = string
  description = "Resource group name"
}


variable "virtual_network_name" {
  description = "The name of the virtual network"
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
  description = "The name of the delegated subnet."
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


## ADBS variables
#**NOTE:** Please refer to autonomous database official documentation.
variable "db_name" {
  type        = string
  description = "Database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted "
}
variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "Password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (“) or the username “admin”, regardless of casing."
}

variable "db_compute_model" {
  type        = string
  default     = "ECPU"
  description = "Compute model of the Autonomous Database"
}
variable "db_ecpu_count" {
  type        = number
  description = "Number of CPU cores to be made available to the database"
}
variable "db_storage_in_gb" {
  type        = number
  description = "Size, in gigabytes, of the data volume that will be created and attached to the database"
}
variable "db_version" {
  type        = string
  default     = "19c"
  description = "Oracle Database version for Autonomous Database"
}

variable "db_license_model" {
  type        = string
  default     = "LicenseIncluded"
  description = "License model either LicenseIncluded or BringYourOwnLicense"
}
variable "db_workload" {

  type        = string
  default     = "DW"
  description = "Autonomous Database workload type"
}
variable "db_auto_scale_enabled" {
  type        = bool
  default     = true
  description = "Auto scaling is enabled for the Autonomous Database CPU core count"
}
variable "db_storage_auto_scale_enabled" {
  type        = bool
  default     = false
  description = "Auto scaling is enabled for the Autonomous Database storage."
}

variable "db_permission_level" {
  type        = string
  default     = "Restricted"
  description = "Autonomous Database permission level. Restricted mode allows access only by admin users"
}
variable "db_type" {
  type        = string
  default     = "Regular"
  description = "Database type"
}
variable "db_character_set" {
  type        = string
  default     = "AL32UTF8"
  description = "Character set for the Autonomous Database"
}
variable "db_n_character_set" {
  type        = string
  default     = "AL16UTF16"
  description = "Character set for the Autonomous Database"
}
