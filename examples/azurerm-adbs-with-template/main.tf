# Avoid storing your admin password in Terraform configuration and follow TF best practices. 
# You can assign the value via environment variables or -var option in your pipeline.
# https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line 
# https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name
variable "admin_password" {
  description = "Admin password of ADB-S."
  type        = string
  sensitive   = true
  default     = "Your0wnDefaultPw"
}

# Provision ADB-S with new VNET and Resource Group
module "azurerm-oci-adbs-quickstart"{
  source         = "../../templates/azurerm-oci-adbs-quickstart"
  az_region      = "ukwest"
  name           = "oraadbs"
  admin_password = var.admin_password
  new_vnet = true
  new_rg = true
}

# Provision ADB-S with existing VNET and Resource Group
# module "azurerm-oci-adbs-quickstart_existing" {
#   # source = "github.com/oci-landing-zones/terraform-oci-multicloud-azure//templates/azurerm-oci-adbs-quickstart"
#   source               = "../../templates/azurerm-oci-adbs-quickstart"
#   az_region            = "ukwest"
#   name                 = "oraadbs"
#   random_suffix_length = "0"
#   admin_password       = var.admin_password

#   new_rg         = false
#   resource_group = "rg-existing"

#   new_vnet              = false
#   virtual_network_name  = "vnet-oci"
#   delegated_subnet_name = "snet-delegate-oci"

# }
