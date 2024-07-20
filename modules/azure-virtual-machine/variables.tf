variable "exa_infra_vm_cluster_resource_group" {
  type        = string
  description = "The name of Exadata Infrastructure and VM Cluster resource group."
}

variable "location" {
  description = "The location of the virtual machine resource."
  type        = string
}

variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_subnet_id" {
  description = "The subnet Id of the virtual machine."
  type        = string
}

variable "ssh_public_key" {
  description = "The ssh public key of the virtual machine."
  type        = string
}

variable "vm_vnet_resource_group" {
  description = "The resource group of the VM's virtual network."
  type        = string
}

variable "vm_vnet_name" {
  description = "The virtual network name of the virtual machine."
  type        = string
}

variable "vm_vnet_id" {
  description = "The virtual network Id of the virtual machine."
  type        = string
}

variable "vm_cluster_vnet_id" {
  description = "The virtual network Id of the VM Cluster."
  type        = string
}

variable "vm_cluster_vnet_resource_group" {
  description = "The resource group of the VM Cluster's virtual network."
  type        = string
}

variable "vm_cluster_vnet_name" {
  description = "The virtual network name of the VM Cluster."
  type        = string
}