variable "location" {
  description = "The Azure region where the virtual network should exist."
  type        = string
}

variable "name" {
  description = "The virtual network name."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group where the virtual network should exist."
  type        = string
}

variable "address_space" {
  description = "The address space prefixes for the virtual network."
  type        = list(string)
  default     = null
}

variable "virtual_network_address_space" {
  description = "Single address space prefix for the virtual network. Used when address_space is not provided."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnet map passed to the Azure Verified Module. If omitted, a delegated Oracle Database@Azure subnet is created."
  type        = any
  default     = null
}

variable "delegated_subnet_name" {
  description = "The name of the delegated Oracle Database@Azure subnet. Used when subnets is not provided."
  type        = string
  default     = "delegated"
}

variable "delegated_subnet_address_prefix" {
  description = "The address prefix for the delegated Oracle Database@Azure subnet. Used when subnets is not provided."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the virtual network."
  type        = map(string)
  default     = null
}
