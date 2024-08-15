terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  location             = var.location
  resource_group_name  = var.exa_infra_vm_cluster_resource_group
  virtual_machine_name = var.virtual_machine_name
  vnet_peering         = var.vm_vnet_id != var.vm_cluster_vnet_id
}

resource "azurerm_public_ip" "public-ip" {
  allocation_method   = "Static"
  location            = local.location
  name                = "${local.virtual_machine_name}-ip"
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  depends_on = [
  ]
}

resource "azurerm_network_interface" "network-interface" {
  enable_accelerated_networking = true
  location                      = local.location
  name                          = "${local.virtual_machine_name}-network-interface"
  resource_group_name           = local.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
    subnet_id                     = var.vm_subnet_id
  }
  depends_on = [
    azurerm_public_ip.public-ip,
  ]
}

resource "azurerm_linux_virtual_machine" "virtual-machine" {
  admin_username        = "azureuser"
  location              = local.location
  name                  = local.virtual_machine_name
  network_interface_ids = [azurerm_network_interface.network-interface.id]
  resource_group_name   = local.resource_group_name
  secure_boot_enabled   = true
  size                  = var.vm_size
  vtpm_enabled          = true
  additional_capabilities {
  }
  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = "azureuser"
  }
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "Oracle-Linux"
    publisher = "Oracle"
    sku       = "ol88-lvm-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.network-interface,
  ]
}

resource "azurerm_network_security_group" "network-security-group" {
  location            = local.location
  name                = "${local.virtual_machine_name}-nsg"
  resource_group_name = local.resource_group_name
  depends_on = [
    azurerm_network_interface.network-interface
  ]
}

resource "azurerm_network_interface_security_group_association" "network-interface-nsg-association" {
  network_interface_id      = azurerm_network_interface.network-interface.id
  network_security_group_id = azurerm_network_security_group.network-security-group.id
  depends_on = [
    azurerm_network_interface.network-interface,
    azurerm_network_security_group.network-security-group,
  ]
}

resource "azurerm_network_security_rule" "nsg-rule" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.network-security-group.name
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = local.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.network-security-group,
  ]
}
