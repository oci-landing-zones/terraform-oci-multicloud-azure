# azurerm-ora-adbs

## Summary
Terraform module for Oracle Database @ Azure AutonomousDatabase (using AzureRM Terraform Provider)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_oracle_autonomous_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/oracle_autonomous_database) | resource |
| [azurerm_oracle_autonomous_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/oracle_autonomous_database) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password must be between 12 and 30characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol or the username 'admin', regardless of casing. | `string` | n/a | yes |
| <a name="input_auto_scaling_enabled"></a> [auto\_scaling\_enabled](#input\_auto\_scaling\_enabled) | Indicates if auto scaling is enabled for the Autonomous Database CPU core count. The default value is true. | `bool` | `true` | no |
| <a name="input_auto_scaling_for_storage_enabled"></a> [auto\_scaling\_for\_storage\_enabled](#input\_auto\_scaling\_for\_storage\_enabled) | Indicates if auto scaling is enabled for the Autonomous Database storage. The default value is false. | `bool` | `false` | no |
| <a name="input_backup_retention_period_in_days"></a> [backup\_retention\_period\_in\_days](#input\_backup\_retention\_period\_in\_days) | Retention period, in days, for backups. | `number` | `60` | no |
| <a name="input_character_set"></a> [character\_set](#input\_character\_set) | The character set for the autonomous database. The default is AL32UTF8 | `string` | `"AL32UTF8"` | no |
| <a name="input_compute_count"></a> [compute\_count](#input\_compute\_count) | The compute amount (CPUs) available to the database. Minimum and maximum values depend on the compute model and whether the database is an Autonomous Database Serverless instance or an Autonomous Database on Dedicated Exadata Infrastructure. For an Autonomous Database Serverless instance, the ECPU compute model requires a minimum value of one, for databases in the elastic resource pool and minimum value of two, otherwise. Required when using the computeModel parameter. When using cpuCoreCount parameter, it is an error to specify computeCount to a non-null value. Providing computeModel and computeCount is the preferred method for both OCPU and ECPU. | `number` | `2` | no |
| <a name="input_compute_model"></a> [compute\_model](#input\_compute\_model) | The compute model of the Autonomous Database. This is required if using the computeCount parameter. If using cpuCoreCount then it is an error to specify computeModel to a non-null value. ECPU compute model is the recommended model and OCPU compute model is legacy. | `string` | `"ECPU"` | no |
| <a name="input_customer_contacts"></a> [customer\_contacts](#input\_customer\_contacts) | The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses. | `list(string)` | `[]` | no |
| <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs) | The maximum storage that can be allocated for the database, in terabytes. | `number` | `1` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | A valid Oracle Database version for Autonomous Database. | `string` | `"19c"` | no |
| <a name="input_db_workload"></a> [db\_workload](#input\_db\_workload) | The Autonomous Database workload type. The following values are valid: OLTP, DW, AJD, APEX | `string` | `"OLTP"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The user-friendly name for the Autonomous Database in OCI. The name does not have to be unique. | `string` | n/a | yes |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Oracle Database service. Note that when provisioning an Autonomous Database on dedicated Exadata infrastructure, this attribute must be null. It is already set at the Autonomous Exadata Infrastructure level. When provisioning an Autonomous Database Serverless database, if a value is not specified, the system defaults the value to BRING\_YOUR\_OWN\_LICENSE. Bring your own license (BYOL) also allows you to select the DB edition using the optional parameter. | `string` | `"LicenseIncluded"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Autonomous Database should exist. Changing this forces a new Autonomous Database to be created | `string` | n/a | yes |
| <a name="input_mtls_connection_required"></a> [mtls\_connection\_required](#input\_mtls\_connection\_required) | Specifies if the Autonomous Database requires mTLS connections. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure resource name which should be used for this Autonomous Database. | `string` | n/a | yes |
| <a name="input_national_character_set"></a> [national\_character\_set](#input\_national\_character\_set) | The national character set for the autonomous database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8. | `string` | `"AL16UTF16"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of Resource Group in Azure | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet the resource is associated with. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags for the Cloud Exadata Infrastructure | `map(string)` | `null` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | The ID of the vnet associated with the autonomous database. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_adbs_ocid"></a> [oci\_adbs\_ocid](#output\_oci\_adbs\_ocid) | OCID of Autonomous Database in OCI |
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | Compartment OCID of the Autonomous Database in OCI |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | Region of the Autonomous Database in OCI |
| <a name="output_resource"></a> [resource](#output\_resource) | Resource Object of Autonomous Database in Azure |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | Resource ID of Autonomous Database in Azure |
<!-- END_TF_DOCS -->