variable "group_prefix" {
  type        = string
  default     = ""
  description = "Group name prefix in Azure"
}

variable "adbs_rbac" {
  type        = bool
  default     = false
  description = "Setup RBAC for ADB-S in Azure. Default is false."
}
variable "exa_rbac" {
  type        = bool
  default     = false
  description = "Setup RBAC for Exa in Azure. Default is false."
}