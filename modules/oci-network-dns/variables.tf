variable "tags" {
  description = "Resource tags to be assigned for OCI resources"
  type        = map(string)
  default     = null
}

variable "compartment_id" {
  description = "OCID of OCI Compartment"
  type = string
}

variable "dns_view_name" {
  description = "Name of DNS View"
  type = string
}

variable "dns_zone_name" {
  description = "Name of DNS Zone"
  type = string
}

variable "scope" {
  description = "Scope of DNS View and DNS Zone. Default is PRIVATE"
  type = string
  default = "PRIVATE"
}