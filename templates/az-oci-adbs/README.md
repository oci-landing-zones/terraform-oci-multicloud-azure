# Quickstart OracleDB@Azure (Autonomous Database) with OCI LZ modules (AzAPI)

## Summary
This is a Terraform Template for provisioning Oracle Database@Azure with the following resources using AzAPI Terraform provider

- Azure Resource Group (AzureRM) - Optional
- Azure VNet with a delegated subnet for OracleDB@Azure (AzureRM/AVM)
- Oracle Autonomous Database (AzAPI)

> [!NOTE]  
> Since there are limited properties updatable from Azure at the moment (either Azure Portal or using AzAPI/AzureRM Terraform Provider), the reference implementation is making use of [ignore_changes in lifecycle block](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes) to avoid having a force replacement plan when changes are made via other means (e.g. OCI Console)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.99.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_network"></a> [avm\_network](#module\_avm\_network) | Azure/avm-res-network-virtualnetwork/azurerm | 0.2.4 |
| <a name="module_azure-oracle-adbs"></a> [azure-oracle-adbs](#module\_azure-oracle-adbs) | ../../modules/azure-oracle-adbs | n/a |
| <a name="module_azure-resource-grp"></a> [azure-resource-grp](#module\_azure-resource-grp) | ../../modules/azure-resource-grp | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password must be between 12 and 30characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol or the username 'admin', regardless of casing. | `string` | n/a | yes |
| <a name="input_auto_scaling_enabled"></a> [auto\_scaling\_enabled](#input\_auto\_scaling\_enabled) | Indicates if auto scaling is enabled for the Autonomous Database CPU core count. The default value is true. | `bool` | `true` | no |
| <a name="input_auto_scaling_for_storage_enabled"></a> [auto\_scaling\_for\_storage\_enabled](#input\_auto\_scaling\_for\_storage\_enabled) | Indicates if auto scaling is enabled for the Autonomous Database storage. The default value is false. | `bool` | `false` | no |
| <a name="input_avm_enable_telemetry"></a> [avm\_enable\_telemetry](#input\_avm\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the Azure Verified Modules | `bool` | `true` | no |
| <a name="input_az_region"></a> [az\_region](#input\_az\_region) | The location of the resources on Azure. e.g. useast | `string` | n/a | yes |
| <a name="input_backup_retention_period_in_days"></a> [backup\_retention\_period\_in\_days](#input\_backup\_retention\_period\_in\_days) | Retention period, in days, for backups. | `number` | `60` | no |
| <a name="input_character_set"></a> [character\_set](#input\_character\_set) | The character set for the autonomous database. The default is AL32UTF8 | `string` | `"AL32UTF8"` | no |
| <a name="input_compute_count"></a> [compute\_count](#input\_compute\_count) | The compute amount (CPUs) available to the database. Minimum and maximum values depend on the compute model and whether the database is an Autonomous Database Serverless instance or an Autonomous Database on Dedicated Exadata Infrastructure. For an Autonomous Database Serverless instance, the ECPU compute model requires a minimum value of one, for databases in the elastic resource pool and minimum value of two, otherwise. Required when using the computeModel parameter. When using cpuCoreCount parameter, it is an error to specify computeCount to a non-null value. Providing computeModel and computeCount is the preferred method for both OCPU and ECPU. | `number` | `2` | no |
| <a name="input_compute_model"></a> [compute\_model](#input\_compute\_model) | The compute model of the Autonomous Database. This is required if using the computeCount parameter. If using cpuCoreCount then it is an error to specify computeModel to a non-null value. ECPU compute model is the recommended model and OCPU compute model is legacy. | `string` | `"ECPU"` | no |
| <a name="input_customer_contacts"></a> [customer\_contacts](#input\_customer\_contacts) | The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses. | <pre>list(object({<br/>    email = string<br/>  }))</pre> | `[]` | no |
| <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs) | The maximum storage that can be allocated for the database, in terabytes. | `number` | `1` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | A valid Oracle Database version for Autonomous Database. | `string` | `"23ai"` | no |
| <a name="input_db_workload"></a> [db\_workload](#input\_db\_workload) | The Autonomous Database workload type. The following values are valid: OLTP, DW, AJD, APEX | `string` | `"DW"` | no |
| <a name="input_delegated_subnet_address_prefix"></a> [delegated\_subnet\_address\_prefix](#input\_delegated\_subnet\_address\_prefix) | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24 | `string` | n/a | yes |
| <a name="input_delegated_subnet_name"></a> [delegated\_subnet\_name](#input\_delegated\_subnet\_name) | The name of the delegated subnet. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The user-friendly name for the Autonomous Database. The name does not have to be unique. | `string` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Oracle Database service. | `string` | `"BringYourOwnLicense"` | no |
| <a name="input_local_adg_auto_failover_max_data_loss_limit"></a> [local\_adg\_auto\_failover\_max\_data\_loss\_limit](#input\_local\_adg\_auto\_failover\_max\_data\_loss\_limit) | Parameter that allows users to select an acceptable maximum data loss limit in seconds, up to which Automatic Failover will be triggered when necessary for a Local Autonomous Data Guard | `number` | `0` | no |
| <a name="input_local_dataguard_enabled"></a> [local\_dataguard\_enabled](#input\_local\_dataguard\_enabled) | Indicates whether the Autonomous Database has local or called in-region Data Guard enabled. | `bool` | `false` | no |
| <a name="input_mtls_connection_required"></a> [mtls\_connection\_required](#input\_mtls\_connection\_required) | Specifies if the Autonomous Database requires mTLS connections. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name which should be used for this Autonomous Database. | `string` | n/a | yes |
| <a name="input_national_character_set"></a> [national\_character\_set](#input\_national\_character\_set) | The national character set for the autonomous database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8. | `string` | `"AL16UTF16"` | no |
| <a name="input_new_rg"></a> [new\_rg](#input\_new\_rg) | Create new resource group or not | `bool` | `true` | no |
| <a name="input_open_mode"></a> [open\_mode](#input\_open\_mode) | Indicates the Autonomous Database mode. The database can be opened in READ\_ONLY or READ\_WRITE mode. | `string` | `"ReadWrite"` | no |
| <a name="input_permission_level"></a> [permission\_level](#input\_permission\_level) | The Autonomous Database permission level. Restricted mode allows access only by admin users. | `string` | `"Unrestricted"` | no |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | # Mandatory to randomise namaing for resource group, exadata infra and vmcluster | `number` | `3` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource Group Name | `string` | `"rg-oradb"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | resource tags | `map(string)` | <pre>{<br/>  "createdby": "az-oci-adbs"<br/>}</pre> | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space of the virtual network. e.g. 10.2.0.0/16 | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network | `string` | n/a | yes |
| <a name="input_whitelisted_ips"></a> [whitelisted\_ips](#input\_whitelisted\_ips) | The client IP access control list (ACL). This is an array of CIDR notations and/or IP addresses. Values should be separate strings, separated by commas. Example: ['1.1.1.1','1.1.1.0/24','1.1.2.25'] | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->