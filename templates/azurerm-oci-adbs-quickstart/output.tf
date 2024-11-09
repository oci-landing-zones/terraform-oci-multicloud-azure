# Azure info
output "az_resource_group_name" {
  description = "Name of Resource Group in Azure"
  value = module.azure-resource-grp.resource_group_name
}

output "az_vnet_id" {
  description = "Resource ID of Azure VNet"
  value = module.avm_network.resource_id
}

output "az_ora_adbs_resource_id" {
  description = "Azure Resource ID of Oracle Autonomous Database"
  value = module.azurerm_ora_adbs.resource_id
}

# output "az_ora_adbs_resource" {
#   description = "Azure Resource ID of Oracle Autonomous Database"
#   value = module.azurerm_ora_adbs.resource
# }

# OCI info
output "oci_adbs_ocid" {
  description = "OCID of Autonomous Database in OCI"
  value = module.azurerm_ora_adbs.oci_adbs_ocid
}

output "oci_region" {
  description = "OCI region"
  value = module.azurerm_ora_adbs.oci_region
}

output "oci_compartment_ocid" {
  description = "OCID of Compartment in OCI"
  value = module.azurerm_ora_adbs.oci_compartment_ocid
}
