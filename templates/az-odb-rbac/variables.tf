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