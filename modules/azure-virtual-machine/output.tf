output "vm_public_ip_address" {
  value = azurerm_linux_virtual_machine.virtual-machine.public_ip_address
}