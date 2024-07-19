variable "exa_infra_vm_cluster_resource_group" {
  type        = string
  description = "The name of Exadata Infrastructure and VM Cluster resource group"
}

variable "location" {
  description = "The location of the network resources."
  type        = string
}

variable "virtual_machine_name" {
  description = "virtual machine name"
  type        = string
}

variable "vm_subnet_id" {
  description = ""
  type        = string
}

variable "ssh_public_key" {
  type = string
}

variable "vm_vnet_resource_group" {
  type = string
}
variable "vm_vnet_name" {
  type = string
}
variable "vm_cluster_vnet_id" {
  type = string
}

variable "vm_cluster_vnet_resource_group" {
  type = string
}
variable "vm_cluster_vnet_name" {
  type = string
}
variable "vm_vnet_id" {
  type = string
}