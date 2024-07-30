variable "location" {
  description = "Specifies the Azure location where would like to get limits increased."
}

variable "zones" {
  type = string
  description = "The Azure logicalZones would like to get limits increased."
  default = ""
}