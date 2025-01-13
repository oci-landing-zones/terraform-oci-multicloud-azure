variable "name" {
  description = "Name of the resource"
  type = string
}

variable "resource_group_name" {
  description = "Name of Resource Group"
  type = string
}

variable "resource_type" {
  description = "Supported valid values: cloud-exadata-infrastructure, cloud-vm-cluster, autonomous-database"
  type = string
}

