output "resource" {
    description = "Resource Object of VM Cluster in Azure"
    value = data.azurerm_oracle_cloud_vm_cluster.this
}

output "resource_id" {
    description = "Resource ID of the VM Cluster in Azure"
    value = azurerm_oracle_cloud_vm_cluster.this.id
}

output "vm_cluster_ocid" {
    description = "OCID of the VM Cluster in OCI"
    value = data.azurerm_oracle_cloud_vm_cluster.this.ocid
}

output "vm_cluster_hostname_actual" {
    description = "The actual hostname of the VM Cluster after provision"
    value = data.azurerm_oracle_cloud_vm_cluster.this.hostname_actual
}

output "oci_region" {
  description = "Region of the VM Cluster in OCI"
    value = regex("(?:region=)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.oci_url)[0]
}

output "oci_compartment_ocid" {
  description = "Compartment OCID of the VM Cluster in OCI"
    value = regex("(?:compartmentId=)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.oci_url)[0]
}

output "oci_vcn_ocid" {
    description = "OCID of the Virtual Cloud Network (VCN)in OCI"
    value = regex("(?:networking/vcns/)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.nsg_url)[0]
}

output "oci_nsg_ocid" {
    description = "OCID of the Network Security Group (NSG) in OCI"
    value = regex("(?:network-security-groups/)([^?&/]+)",data.azurerm_oracle_cloud_vm_cluster.this.nsg_url)[0]
}
