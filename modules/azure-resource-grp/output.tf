output "resource_group_id" {
  value     = data.azurerm_resource_group.this.id
}

output "resource_group_name" {
  value     = data.azurerm_resource_group.this.name
}