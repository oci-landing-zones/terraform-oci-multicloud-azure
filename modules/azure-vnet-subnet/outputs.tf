output "virtual_network_id" {
  value = azurerm_virtual_network.virtual-network.id
}

output "delegated_subnet_id" {
  value = azurerm_subnet.delegated-subnet.id
}