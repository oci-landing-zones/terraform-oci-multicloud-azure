# azure-oracle-adbs

## Summary

Terraform module for **Oracle Autonomous Database Serverless (ADB-S)** , Creates a new Autonomous Database resource in Oracle Database @ Azure.

> [!NOTE]  
> Since there are limited properties updatable from Azure at the moment (either Azure Portal or using AzAPI/AzureRM Terraform Provider), the reference implementation is making use of [ignore_changes in lifecycle block](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes) to avoid having a force replacement plan when changes are made via other means (e.g. OCI Console)

## Pre-requisites

A virtual network with subnet delegated to `Oracle.Database/networkAttachment` present in targetted subscription.

<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.autonomous_db](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [null_resource.wait_until_available](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

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
| <a name="input_customer_contacts"></a> [customer\_contacts](#input\_customer\_contacts) | The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses. | <pre>list(object({<br/>    email = string<br/>  }))</pre> | `[]` | no |
| <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs) | The maximum storage that can be allocated for the database, in terabytes. | `number` | `1` | no |
| <a name="input_db_resource_group"></a> [db\_resource\_group](#input\_db\_resource\_group) | Autonomous Database resource group name | `string` | n/a | yes |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | A valid Oracle Database version for Autonomous Database. | `string` | `"23ai"` | no |
| <a name="input_db_workload"></a> [db\_workload](#input\_db\_workload) | The Autonomous Database workload type. The following values are valid: OLTP, DW, AJD, APEX | `string` | `"DW"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The user-friendly name for the Autonomous Database. The name does not have to be unique. | `string` | `""` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Oracle Database service. | `string` | `"BringYourOwnLicense"` | no |
| <a name="input_local_adg_auto_failover_max_data_loss_limit"></a> [local\_adg\_auto\_failover\_max\_data\_loss\_limit](#input\_local\_adg\_auto\_failover\_max\_data\_loss\_limit) | Parameter that allows users to select an acceptable maximum data loss limit in seconds, up to which Automatic Failover will be triggered when necessary for a Local Autonomous Data Guard | `number` | `0` | no |
| <a name="input_local_dataguard_enabled"></a> [local\_dataguard\_enabled](#input\_local\_dataguard\_enabled) | Indicates whether the Autonomous Database has local or called in-region Data Guard enabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Resource region | `string` | n/a | yes |
| <a name="input_mtls_connection_required"></a> [mtls\_connection\_required](#input\_mtls\_connection\_required) | Specifies if the Autonomous Database requires mTLS connections. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name which should be used for this Autonomous Database. | `string` | n/a | yes |
| <a name="input_national_character_set"></a> [national\_character\_set](#input\_national\_character\_set) | The national character set for the autonomous database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8. | `string` | `"AL16UTF16"` | no |
| <a name="input_nw_delegated_subnet_name"></a> [nw\_delegated\_subnet\_name](#input\_nw\_delegated\_subnet\_name) | Oracle delegate subnet name | `string` | n/a | yes |
| <a name="input_nw_resource_group"></a> [nw\_resource\_group](#input\_nw\_resource\_group) | Virtual network resource group name | `string` | n/a | yes |
| <a name="input_nw_vnet_name"></a> [nw\_vnet\_name](#input\_nw\_vnet\_name) | Virtual network name | `string` | n/a | yes |
| <a name="input_open_mode"></a> [open\_mode](#input\_open\_mode) | Indicates the Autonomous Database mode. The database can be opened in READ\_ONLY or READ\_WRITE mode. | `string` | `"ReadWrite"` | no |
| <a name="input_permission_level"></a> [permission\_level](#input\_permission\_level) | The Autonomous Database permission level. Restricted mode allows access only by admin users. | `string` | `"Unrestricted"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of the resource. | `map(string)` | <pre>{<br/>  "TF-MOD": "azure-oracle-adbs"<br/>}</pre> | no |
| <a name="input_whitelisted_ips"></a> [whitelisted\_ips](#input\_whitelisted\_ips) | The client IP access control list (ACL). This is an array of CIDR notations and/or IP addresses. Values should be separate strings, separated by commas. Example: ['1.1.1.1','1.1.1.0/24','1.1.2.25'] | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autonomous_db_id"></a> [autonomous\_db\_id](#output\_autonomous\_db\_id) | n/a |
| <a name="output_autonomous_db_ocid"></a> [autonomous\_db\_ocid](#output\_autonomous\_db\_ocid) | n/a |
| <a name="output_autonomous_db_properties"></a> [autonomous\_db\_properties](#output\_autonomous\_db\_properties) | n/a |
<!-- END_TF_DOCS -->