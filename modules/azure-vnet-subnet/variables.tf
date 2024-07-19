variable "resource_group_name" {
  type        = string
  description = "The name of Azure resource group"
}

variable "location" {
  description = "The location of the network resources."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "virtual_network_address_space" {
  description = "The address space of the virtual network. e.g. 10.2.0.0/16"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.virtual_network_address_space))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "delegated_subnet_address_prefix" {
  description = "The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.delegated_subnet_address_prefix))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "delegated_subnet_name" {
  description = "The name of the delegated subnet."
  type        = string
  default = ""
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default = ""
}
