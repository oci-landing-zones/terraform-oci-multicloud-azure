output "resource_id" {
  value = azurerm_oracle_exadata_infrastructure.this.id
}

output "resource" {
  value = azurerm_oracle_exadata_infrastructure.this
}

output "oci_region" {
    value = regex("(?:region=)([^?&/]+)",data.azurerm_oracle_exadata_infrastructure.this.oci_url)[0]
}

output "oci_compartment_ocid" {
    value = regex("(?:compartmentId=)([^?&/]+)",data.azurerm_oracle_exadata_infrastructure.this.oci_url)[0]
}
