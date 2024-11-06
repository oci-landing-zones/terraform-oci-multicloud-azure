# Azure info
output "az_resource_group_name" {
  description = "Name of Resource Group in Azure"
  value = module.azure-resource-grp.resource_group_name
}

output "az_vnet_id" {
  description = "Resource ID of Azure VNet"
  value = module.avm_network.resource_id
}

output "az_exadata_infra_id" {
  description = "Resource ID of Exadata Infrastructure from Azure"
  value = module.azurerm_exadata_infra.resource_id
}

# output "az_exadata_infra_resource" {
#   value =  module.azurerm_exadata_infra.resource
# }

output "az_vm_cluster_id" {
  description = "Resource ID of VM Cluster from Azure"
  value = module.azurerm_exadata_vmc.resource_id
}

# output "az_vm_cluster_resource" {
#   value =  module.azurerm_exadata_vmc.resource
# }

# OCI Info
output "oci_compartment_ocid" {
    value = local.oci_compartment_ocid
}

output "oci_region" {
    value = module.azurerm_exadata_vmc.oci_region
}

output "oci_vcn_id" {
    value = local.oci_vcn_ocid
}

output "oci_nsg_id" {
    value = local.oci_nsg_ocid
}

output "oci_vm_cluster_id" {
  description = "OCID of VM Cluster from Azure for OCI"
  value = module.azurerm_exadata_vmc.vm_cluster_ocid
}

output "oci_db_home_id" {
  description = "OCID of Oracle Database Home from OCI"
  value = module.oci-database-db-home[0].db_home_id[0]
}

output "oci_cdb_name" {
  description = "Name of the Oracle Container Database from OCI"
  value = data.oci_database_databases.cdb.databases[0].db_name
}

output "oci_cdb_id" {
  description = "OCID of the Oracle Container Database from OCI"
  value = data.oci_database_databases.cdb.databases[0].id
}

output "oci_cdb_connection_strings" {
  description = "OCID of the Oracle Container Database from OCI"
  value = data.oci_database_databases.cdb.databases[0].connection_strings[0].cdb_ip_default
}

# output "oci_pdb_name" {
#   description = "Name of the Oracle Pluggable Database from OCI"
#   value = data.oci_database_pluggable_databases.pdb.pluggable_databases[0].pdb_name
# }

# output "oci_pdb_id" {
#   description = "OCID of the Oracle Pluggable Database from OCI"
#   value = data.oci_database_pluggable_databases.pdb.pluggable_databases[0].id
# }

# output "oci_pdb_connection_strings" {
#   description = "OCID of the Oracle Pluggable Database from OCI"
#   value = data.oci_database_pluggable_databases.pdb.pluggable_databases[0].connection_strings[0].pdb_ip_default
# }
