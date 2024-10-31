output "resource_id" {
  description = "Resource ID of Exadata Infrastructure in Azure"
  value = azurerm_oracle_exadata_infrastructure.this.id
}

output "resource" {
  description = "Resource Object of Exadata Infrastructure in Azure"
  value = azurerm_oracle_exadata_infrastructure.this
}

output "oci_region" {
  description = "Region of the Exadata Infrastructure in OCI"
  value = regex("(?:region=)([^?&/]+)",data.azurerm_oracle_exadata_infrastructure.this.oci_url)[0]
}

output "oci_compartment_ocid" {
  description = "Compartment OCID of the Exadata Infrastructure in OCI"
  value = regex("(?:compartmentId=)([^?&/]+)",data.azurerm_oracle_exadata_infrastructure.this.oci_url)[0]
}
