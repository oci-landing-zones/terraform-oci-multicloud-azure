# Avoid storing your admin password in Terraform configuration and follow TF best practices. 
# You can assign the value via environment variables or -var option in your pipeline.
# https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line 
# https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name


provider "azurerm" {
  features {}
}

# Provision ADB-S in existing VNET and Resource Group with modules/azurerm-ora-adbs
module "azurerm-oci-adbs-quickstart_existing" {
  source = "github.com/oci-landing-zones/terraform-oci-multicloud-azure//modules/azurerm-ora-adbs"
  # source               = "../../modules/azurerm-ora-adbs"

  resource_group_name = "rg-existing"
  location            = "ukwest"

  virtual_network_id = "/subscriptions/xxxxx/resourceGroups/xxxxx/providers/Microsoft.Network/virtualNetworks/xxxxx"
  subnet_id          = "/subscriptions/xxxxx/resourceGroups/xxxxx/providers/Microsoft.Network/virtualNetworks/xxxxx/subnets/xxxxx"

  name           = "oraadbs"
  display_name   = "oraadbs"
  admin_password = var.admin_password
}

