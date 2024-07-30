variable "location" {
  description = "Specifies the Azure location where would like to get limits increased."
}

variable "zones" {
  type = string
  description = "The Azure logicalZones would like to get limits increased."
  default = ""
}

variable "az_far_child_site" {
  type = string
  description = "Azure Far Child Site, e.g. IAD53, IAD52, or N/A>"
  default = "N/A"
}