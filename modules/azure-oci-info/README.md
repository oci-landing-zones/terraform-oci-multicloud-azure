# azure-oci-info

This module extract OCI identifiers (such as region, tenancy and OCIDs) that assocate with the given Oracle Database@Azure resource.

- Some Azure Verified Modules (AVMs) require Terraform version "~> 3.71" and "~> 3.74", conflicting the AzureRM version requirement of Oracle Exadata ">= 4.9.0"
- This module is getting information using AZ CLI, instead of AzureRM, to serve as a workaround that works with both AVM-based and AzureRM-based implementation.
- This module also eliminiated the dependency of JSON mapping data file by deducing information from CLI output directly.

## Requirements

This module requires Azure CLI, which is the [prerequisites of AzureRM Terraform Provider](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#prerequisites).

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

## Resources

| Name | Type |
|------|------|
| [external_external.az_exadata_infra](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of Resource Group | `string` | n/a | yes |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | Supported valid values: cloud-exadata-infrastructure, cloud-vm-cluster, autonomous-database | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | n/a |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | n/a |
| <a name="output_oci_resource_ocid"></a> [oci\_resource\_ocid](#output\_oci\_resource\_ocid) | n/a |
| <a name="output_oci_tenant"></a> [oci\_tenant](#output\_oci\_tenant) | n/a |
<!-- END_TF_DOCS -->
