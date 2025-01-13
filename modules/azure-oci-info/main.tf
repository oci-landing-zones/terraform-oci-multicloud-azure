locals {
  patterns = {
    "cloud-exadata-infrastructure"="cloudexadatainfrastructures"
    "cloud-vm-cluster" = "cloudvmclusters"
    "autonomous-database"= "adbs"
  }
  
  oci_region = regex("(?i:region=)([^?&/]+)",data.external.az_exadata_infra.result.ociUrl)[0]
  oci_compartment_ocid = regex("(?i:compartmentId=)([^?&/]+)",data.external.az_exadata_infra.result.ociUrl)[0]
  oci_tenant = regex("(?i:tenant=)([^?&/]+)",data.external.az_exadata_infra.result.ociUrl)[0]
  oci_resource_ocid = regex("(?i:${local.patterns [var.resource_type]}/)([^?&/]+)",data.external.az_exadata_infra.result.ociUrl)[0]
  
  az_cli_cmd = "az oracle-database ${var.resource_type} show --name ${var.name} --resource-group ${var.resource_group_name} | jq 'with_entries(.value |= tostring)'"
}

data "external" "az_exadata_infra" {
  program = ["sh", "-c", local.az_cli_cmd]
}

