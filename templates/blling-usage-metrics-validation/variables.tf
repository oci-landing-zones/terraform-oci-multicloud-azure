variable "config_file_profile" {
  description = "OCI CLI profile name."
  type        = string
  default     = "DEFAULT"
}

variable "oci_compartment_ocid" {
  description = "Tenancy OCID of root compartment."
  type = string
}

variable "azure_resource_name" {
  description = "The resource group name of the resource."
  type = string
}

variable "azure_resource_group_name" {
  description = "The name of the resource."
  type = string
}