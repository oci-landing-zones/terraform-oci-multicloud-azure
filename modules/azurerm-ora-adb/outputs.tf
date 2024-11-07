output "resource_id" {
  description = "Resource ID of Autonomous Database in Azure"
  value       = azurerm_oracle_autonomous_database.this.id
}

output "resource" {
  description = "Resource Object of Autonomous Database in Azure"
  value       = azurerm_oracle_autonomous_database.this
}

output "oci_region" {
  description = "Region of the Autonomous Database in OCI"
  value = regex("(?:region=)([^?&/]+)",data.azurerm_oracle_autonomous_database.this.oci_url)[0]
}

output "oci_compartment_ocid" {
  description = "Compartment OCID of the Autonomous Database in OCI"
  value = regex("(?:compartmentId=)([^?&/]+)",data.azurerm_oracle_autonomous_database.this.oci_url)[0]
}
