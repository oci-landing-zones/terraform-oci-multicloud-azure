output "resource" {
    value = data.azurerm_oracle_cloud_vm_cluster.this
}

output "resource_id" {
    description = "Resource ID of the VM Cluster from Azure"
    value = azurerm_oracle_cloud_vm_cluster.this.id
}

output "vm_cluster_ocid" {
    description = "OCID of the VM Cluster for OCI"
    value = data.azurerm_oracle_cloud_vm_cluster.this.ocid
}

output "vm_cluster_hostname_actual" {
    description = "The actual hostname of VM Cluster nodes after provision"
    value = data.azurerm_oracle_cloud_vm_cluster.this.hostname_actual
}

output "oci_region" {
    value = regex("(?:region=)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.oci_url)[0]
}

output "oci_compartment_ocid" {
    value = regex("(?:compartmentId=)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.oci_url)[0]
}

output "oci_vcn_ocid" {
    value = regex("(?:networking/vcns/)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.nsg_url)[0]
}

output "oci_nsg_ocid" {
    value = regex("(?:network-security-groups/)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.nsg_url)[0]
}
