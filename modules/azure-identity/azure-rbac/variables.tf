variable "odbaa_built_in_role_assigned_groups" {
  type        = set(string)
  default     = []
  description = "Groups required Built-in Azure Role assigned"
}

variable "odbaa_other_groups" {
  type        = set(string)
  default     = []
  description = "Groups don't require Built-in Azure Role assigned"
}

variable "role_mapping" {
  type        = map(string)
  default     = null
  description = "Group name and Role mapping in Azure"
}
