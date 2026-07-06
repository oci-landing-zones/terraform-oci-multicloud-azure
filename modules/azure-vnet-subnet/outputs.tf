output "resource_id" {
  description = "The Azure resource ID of the virtual network."
  value       = module.vnet_subnet.resource_id
}

output "resource_group_name" {
  description = "The name of the Azure resource group where the virtual network exists."
  value       = var.resource_group_name
}

output "resource" {
  description = "The virtual network resource object."
  value       = module.vnet_subnet.resource
}

output "subnets" {
  description = "The virtual network subnet outputs."
  value       = module.vnet_subnet.subnets
}
