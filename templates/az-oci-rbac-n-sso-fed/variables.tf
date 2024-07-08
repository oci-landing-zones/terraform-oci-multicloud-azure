## these will be passed as param 
variable "config_file_profile" {
  type = string
}

variable "compartment_ocid" {
  description = "for root compartment pass tenancy_ocid , else pass compartment_ocid"
  type        = string
}

variable "region" {
  type = string
}

variable "domain_display_name" {
  type    = string
  default = "Default"
}

variable "confidential_app_name" {
  type    = string
  default = "AzureEntra"
}

#----
variable "az_application_name" {
  type        = string
  default     = "odbaa_app"
  description = "The display name for the application."
}

variable "idp_name" {
  type    = string
  default = "AzureAD"
}

variable "idp_description" {
  type    = string
  default = "" # empty 
}


variable "default_rule_id" {
  type    = string
  default = "DefaultIDPRule"
}

#----- Optional


variable "application_group_name" {
  type        = string
  default     = ""
  description = "User application group name that will be added to the application"
}

variable "user_email" {
  type        = string
  default     = ""
  description = "Existing user email that will be added to the application."
}

variable "group_prefix" {
  type        = string
  default     = ""
  description = "Group name prefix in Azure"
}

variable "rbac" {
  type        = string
  default     = "all"
  description = "Set to \"all\" -- both EXA and ADB-S RBAC(Roles Based Access Control), \"exa\" -- only EXA RBAC(Roles Based Access Control), or \"adbs\" -- only ADB-S RBAC(Roles Based Access Control) to setup Azure RBAC for ODBAA, default is all."
  validation {
    condition     = contains(["all", "exa", "adbs"], var.rbac)
    error_message = "Must be either \"all\", \"exa\", or \"adbs\", default is all."
  }
}
