variable "az_region" {
  description = "The location of the resources on Azure. e.g. useast"
  type        = string
  default = "useast"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "new_rg" {
  type        = bool
  description = "Create new resource group or not"
  default = true
}

variable "az_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}