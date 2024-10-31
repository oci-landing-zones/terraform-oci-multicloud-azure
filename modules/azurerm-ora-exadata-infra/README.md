# azurerm-ora-exadata-infra

## Summary

Terraform module for Oracle Database @ Azure Exadata Infrastructure (using AzureRM Terraform Provider)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_oracle_exadata_infrastructure.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/oracle_exadata_infrastructure) | resource |
| [azurerm_oracle_exadata_infrastructure.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/oracle_exadata_infrastructure) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_count"></a> [compute\_count](#input\_compute\_count) | The number of compute servers for the Exadata infrastructure. | `number` | `2` | no |
| <a name="input_customer_contacts"></a> [customer\_contacts](#input\_customer\_contacts) | The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The name of Azure Region where the Exadata Infrastructure should be. e.g. useast | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | maintenanceWindow properties | <pre>object({<br/>      patching_mode = string<br/>      preference = string<br/>      lead_time_in_weeks = optional(number)<br/>      months = optional(list(number))<br/>      weeks_of_month = optional(list(number))<br/>      days_of_week =optional(list(number))<br/>      hours_of_day = optional(list(number))<br/>  })</pre> | <pre>{<br/>  "patching_mode": "Rolling",<br/>  "preference": "NoPreference"<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Exadata Infrastructure at Azure | `string` | `"odaaz-infra"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of Resource Group in Azure | `string` | `"rg-oradb"` | no |
| <a name="input_shape"></a> [shape](#input\_shape) | The shape of the Exadata infrastructure resource. e.g. Exadata.X9M | `string` | `"Exadata.X9M"` | no |
| <a name="input_storage_count"></a> [storage\_count](#input\_storage\_count) | The number of storage servers for the Exadata infrastructure. | `number` | `3` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags for the Cloud Exadata Infrastructure | `map(string)` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The availablty zone of the Exadata Infrastructure in Azure | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | n/a |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | n/a |
| <a name="output_resource"></a> [resource](#output\_resource) | n/a |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | n/a |
<!-- END_TF_DOCS -->