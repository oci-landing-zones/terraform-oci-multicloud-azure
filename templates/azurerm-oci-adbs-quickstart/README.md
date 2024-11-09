# azurerm-oci-adbs-quickstart

## Summary
This is a Terraform Template for provisioning Oracle Database@Azure with the following resources using AzureRM and OCI Terraform provider

- Azure Resource Group (AzureRM) - Optional
- Azure VNet with a delegated subnet for OracleDB@Azure (AzureRM/AVM)
- Oracle Autonomous Database (AzureRM)

> [!NOTE]  
> This template involving Azure Verified Modules (AVM) which [require Terraform 1.9](https://github.com/Azure/terraform-azurerm-avm-res-oracledatabase-cloudvmcluster/blob/main/terraform.tf) and does not support OpenTofu (which [support up to Terraform 1.8](https://opentofu.org/docs/intro/migration/terraform-1.8/) at the moment).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.1 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.15.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_network"></a> [avm\_network](#module\_avm\_network) | Azure/avm-res-network-virtualnetwork/azurerm | 0.5.0 |
| <a name="module_azure-resource-grp"></a> [azure-resource-grp](#module\_azure-resource-grp) | ../../modules/azure-resource-grp | n/a |
| <a name="module_azurerm_ora_adbs"></a> [azurerm\_ora\_adbs](#module\_azurerm\_ora\_adbs) | ../../modules/azurerm-ora-adbs | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_subnet.delegated_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | resource tags to be used in both Azure and OCI | `map(string)` | <pre>{<br/>  "createdby": "azurerm-oci-adbs-quickstart"<br/>}</pre> | no |
| <a name="input_compute_count"></a> [compute\_count](#input\_compute\_count) | The compute amount (CPUs) available to the database. Minimum and maximum values depend on the compute model and whether the database is an Autonomous Database Serverless instance or an Autonomous Database on Dedicated Exadata Infrastructure. For an Autonomous Database Serverless instance, the ECPU compute model requires a minimum value of one, for databases in the elastic resource pool and minimum value of two, otherwise. Required when using the computeModel parameter. When using cpuCoreCount parameter, it is an error to specify computeCount to a non-null value. Providing computeModel and computeCount is the preferred method for both OCPU and ECPU. | `number` | `2` | no |
| <a name="input_compute_model"></a> [compute\_model](#input\_compute\_model) | The compute model of the Autonomous Database. This is required if using the computeCount parameter. If using cpuCoreCount then it is an error to specify computeModel to a non-null value. ECPU compute model is the recommended model and OCPU compute model is legacy. | `string` | `"ECPU"` | no |
| <a name="input_customer_contacts"></a> [customer\_contacts](#input\_customer\_contacts) | The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses. | `list(string)` | `[]` | no |
| <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs) | The maximum storage that can be allocated for the database, in terabytes. | `number` | `1` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | A valid Oracle Database version for Autonomous Database. | `string` | `"23ai"` | no |
| <a name="input_db_workload"></a> [db\_workload](#input\_db\_workload) | The Autonomous Database workload type. The following values are valid: OLTP, DW, AJD, APEX | `string` | `"DW"` | no |
| <a name="input_delegated_subnet_address_prefix"></a> [delegated\_subnet\_address\_prefix](#input\_delegated\_subnet\_address\_prefix) | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.1.1.0/24 | `string` | `"10.1.1.0/24"` | no |
| <a name="input_delegated_subnet_name"></a> [delegated\_subnet\_name](#input\_delegated\_subnet\_name) | The name of the delegated subnet | `string` | `"snet-delegate-oci"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The user-friendly name for the Autonomous Database. The name does not have to be unique. | `string` | `""` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Oracle Database service. | `string` | `"BringYourOwnLicense"` | no |
| <a name="input_mtls_connection_required"></a> [mtls\_connection\_required](#input\_mtls\_connection\_required) | Specifies if the Autonomous Database requires mTLS connections. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name which should be used for this Autonomous Database. | `string` | n/a | yes |
| <a name="input_national_character_set"></a> [national\_character\_set](#input\_national\_character\_set) | The national character set for the autonomous database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8. | `string` | `"AL16UTF16"` | no |
| <a name="input_new_rg"></a> [new\_rg](#input\_new\_rg) | Create new resource group or not | `bool` | `true` | no |
| <a name="input_oci_config_file_profile"></a> [oci\_config\_file\_profile](#input\_oci\_config\_file\_profile) | OCI Config file name | `string` | `null` | no |
| <a name="input_oci_fingerprint"></a> [oci\_fingerprint](#input\_oci\_fingerprint) | Fingerprint for the key pair being used | `string` | `null` | no |
| <a name="input_oci_private_key_password"></a> [oci\_private\_key\_password](#input\_oci\_private\_key\_password) | Passphrase used for the key, if it's encrypted | `string` | `null` | no |
| <a name="input_oci_private_key_path"></a> [oci\_private\_key\_path](#input\_oci\_private\_key\_path) | The path (including filename) of the private key | `string` | `null` | no |
| <a name="input_oci_tenancy_ocid"></a> [oci\_tenancy\_ocid](#input\_oci\_tenancy\_ocid) | OCID of the OCI tenancy | `string` | `null` | no |
| <a name="input_oci_user_ocid"></a> [oci\_user\_ocid](#input\_oci\_user\_ocid) | OCID of the OCI user | `string` | `null` | no |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | # Mandatory to randomise namaing for resource group, exadata infra and vmcluster | `number` | `3` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource Group Name | `string` | `"rg-oradb"` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space of the virtual network. e.g. 10.1.0.0/16 | `string` | `"10.1.0.0/16"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `"vnet-oci"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_az_ora_adbs_resource_id"></a> [az\_ora\_adbs\_resource\_id](#output\_az\_ora\_adbs\_resource\_id) | Azure Resource ID of Oracle Autonomous Database |
| <a name="output_az_resource_group_name"></a> [az\_resource\_group\_name](#output\_az\_resource\_group\_name) | Name of Resource Group in Azure |
| <a name="output_az_vnet_id"></a> [az\_vnet\_id](#output\_az\_vnet\_id) | Resource ID of Azure VNet |
| <a name="output_oci_adbs_ocid"></a> [oci\_adbs\_ocid](#output\_oci\_adbs\_ocid) | OCID of Autonomous Database in OCI |
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | OCID of Compartment in OCI |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | OCI region |
<!-- END_TF_DOCS -->