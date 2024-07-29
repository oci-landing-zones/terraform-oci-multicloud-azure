variable "location" {
  type        = string
  description = "Resource region"
}

# Network Vars
variable "nw_resource_group" {
  type        = string
  description = "Virtual network resource group name"
}

variable "nw_vnet_name" {
  type        = string
  description = "Virtual network name"
}

variable "nw_delegated_subnet_name" {
  type        = string
  description = "Oracle delegate subnet name"
}

## ADBS variables
#**NOTE:** Please refer to autonomous database official documentation. 
variable "db_resource_group" {
  type        = string
  description = "ADBS resource group name"
}
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
  default     = 2
}
variable "db_storage_in_tbs" {
  type        = number
  description = "Size, in terrabyte, of the data volume that will be created and attached to the database"
  default     = 20
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
