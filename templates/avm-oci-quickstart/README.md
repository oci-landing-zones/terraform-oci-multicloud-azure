# Quickstart OracleDB@Azure (Exadata) with Azure Verified Modules (AzAPI) and OCI LZ Modules

## Summary
This is a Terraform Template for provisioning Oracle Database@Azure with the following resources using Azure Verified Modules (AVM) and OCI LZ Modules.
- Azure Resource Group (Optional)
- Azure VNet with a delegated subnet for OracleDB@Azure (AVM)
- Oracle Exadata Infrastructure (AVM)
- Oracle VM Cluster (AVM)
- Oracle Database Home (OCI)
- Oracle Container Database (OCI)
- Oracle Pluggable Database (OCI)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.2 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.14.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.74 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.1 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.15.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [hashicorp/azurerm](#provider\_azurerm) | 3.74.0 |
| <a name="provider_azapi"></a> [azure/azapi](#provider\_random) | 1.14.0 |
| <a name="provider_oci"></a> [oracle/oci](#provider\_random) | 6.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_exadata_infra"></a> [avm\_exadata\_infra](#module\_avm\_exadata\_infra) | Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm | 0.1.0 |
| <a name="module_avm_exadata_vmc"></a> [avm\_exadata\_vmc](#module\_avm\_exadata\_vmc) | github.com/chanstev/terraform-azurerm-avm-res-oracledatabase-cloudvmcluster | n/a |
| <a name="module_avm_network"></a> [avm\_network](#module\_avm\_network) | Azure/avm-res-network-virtualnetwork/azurerm | 0.2.4 |
| <a name="module_azure-oci-mapping"></a> [azure-oci-mapping](#module\_azure-oci-mapping) | ../../modules/azure-oci-zone-mapping | n/a |
| <a name="module_azure-resource-grp"></a> [azure-resource-grp](#module\_azure-resource-grp) | ../../modules/azure-resource-grp | n/a |
| <a name="module_oci-database-db-home"></a> [oci-database-db-home](#module\_oci-database-db-home) | ../../modules/oci-database-db-home | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_after_deletion](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_subnet.delegated_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avm_enable_telemetry"></a> [avm\_enable\_telemetry](#input\_avm\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the Azure Verified Modules | `bool` | `true` | no |
| <a name="input_az_region"></a> [az\_region](#input\_az\_region) | The location of the resources on Azure. e.g. useast | `string` | `"useast"` | no |
| <a name="input_az_zone"></a> [az\_zone](#input\_az\_zone) | The zone of the exadata infrastructure | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | resource tags to be used in both Azure and OCI | `map(string)` | `null` | no |
| <a name="input_db_admin_password"></a> [db\_admin\_password](#input\_db\_admin\_password) | A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be \_, #, or -. | `string` | n/a | yes |
| <a name="input_db_home_name"></a> [db\_home\_name](#input\_db\_home\_name) | The name of the DB Home | `string` | n/a | yes |
| <a name="input_db_home_source"></a> [db\_home\_source](#input\_db\_home\_source) | The source of database. For Exadata VM Cluster, use VM\_CLUSTER\_NEW | `string` | n/a | yes |
| <a name="input_db_home_version"></a> [db\_home\_version](#input\_db\_home\_version) | A valid Oracle Database version. e.g. 19.20.0.0 | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database | `string` | n/a | yes |
| <a name="input_db_source"></a> [db\_source](#input\_db\_source) | The source of the database: Use NONE for creating a new database. Use DB\_BACKUP for creating a new database by restoring from a backup. | `string` | `"NONE"` | no |
| <a name="input_delegated_subnet_address_prefix"></a> [delegated\_subnet\_address\_prefix](#input\_delegated\_subnet\_address\_prefix) | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24 | `string` | n/a | yes |
| <a name="input_delegated_subnet_name"></a> [delegated\_subnet\_name](#input\_delegated\_subnet\_name) | The name of the delegated subnet | `string` | n/a | yes |
| <a name="input_enable_database_delete"></a> [enable\_database\_delete](#input\_enable\_database\_delete) | Unless enable\_database\_delete is explicitly set to true, Terraform will not delete the database within the Db Home configuration but rather remove it from the config and state file. | `bool` | `false` | no |
| <a name="input_exadata_infrastructure_compute_count"></a> [exadata\_infrastructure\_compute\_count](#input\_exadata\_infrastructure\_compute\_count) | The number of compute servers for the cloud Exadata infrastructure. | `number` | `2` | no |
| <a name="input_exadata_infrastructure_maintenance_window_lead_time_in_weeks"></a> [exadata\_infrastructure\_maintenance\_window\_lead\_time\_in\_weeks](#input\_exadata\_infrastructure\_maintenance\_window\_lead\_time\_in\_weeks) | Lead time window allows user to set a lead time to prepare for a down time. The lead time is in weeks and valid value is between 1 to 4. | `number` | `1` | no |
| <a name="input_exadata_infrastructure_maintenance_window_patching_mode"></a> [exadata\_infrastructure\_maintenance\_window\_patching\_mode](#input\_exadata\_infrastructure\_maintenance\_window\_patching\_mode) | Cloud Exadata infrastructure node patching method, either ROLLING or NONROLLING. | `string` | `"ROLLING"` | no |
| <a name="input_exadata_infrastructure_maintenance_window_preference"></a> [exadata\_infrastructure\_maintenance\_window\_preference](#input\_exadata\_infrastructure\_maintenance\_window\_preference) | The maintenance window scheduling preference.Allowed values are: NO\_PREFERENCE, CUSTOM\_PREFERENCE. | `string` | `"NO_PREFERENCE"` | no |
| <a name="input_exadata_infrastructure_name"></a> [exadata\_infrastructure\_name](#input\_exadata\_infrastructure\_name) | The name of the exadata infrastructure on Azure | `string` | `"odaaz-infra"` | no |
| <a name="input_exadata_infrastructure_shape"></a> [exadata\_infrastructure\_shape](#input\_exadata\_infrastructure\_shape) | The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M | `string` | `"Exadata.X9M"` | no |
| <a name="input_exadata_infrastructure_storage_count"></a> [exadata\_infrastructure\_storage\_count](#input\_exadata\_infrastructure\_storage\_count) | The number of storage servers for the Exadata infrastructure. | `number` | `3` | no |
| <a name="input_new_rg"></a> [new\_rg](#input\_new\_rg) | Create new resource group or not | `bool` | `true` | no |
| <a name="input_nsg_cidrs"></a> [nsg\_cidrs](#input\_nsg\_cidrs) | Add additional Network ingress rules from Azure for the VM cluster's network security group in OCI Virtual Cloud Network (VCN). e.g. [{'source': '0.0.0.0/0','destinationPortRange': {'max': 1522,'min': 1521 }}]. | <pre>list(object({<br/>    source = string,<br/>    destinationPortRange = object({<br/>      min = number<br/>      max = number<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_oci_config_file_profile"></a> [oci\_config\_file\_profile](#input\_oci\_config\_file\_profile) | OCI Config file name | `string` | `"DEFAULT"` | no |
| <a name="input_oci_fingerprint"></a> [oci\_fingerprint](#input\_oci\_fingerprint) | Fingerprint for the key pair being used | `string` | n/a | yes |
| <a name="input_oci_private_key_password"></a> [oci\_private\_key\_password](#input\_oci\_private\_key\_password) | Passphrase used for the key, if it's encrypted | `string` | `null` | no |
| <a name="input_oci_private_key_path"></a> [oci\_private\_key\_path](#input\_oci\_private\_key\_path) | The path (including filename) of the private key | `string` | n/a | yes |
| <a name="input_oci_tenancy_ocid"></a> [oci\_tenancy\_ocid](#input\_oci\_tenancy\_ocid) | OCID of the OCI tenancy | `string` | n/a | yes |
| <a name="input_oci_user_ocid"></a> [oci\_user\_ocid](#input\_oci\_user\_ocid) | OCID of the OCI user | `string` | n/a | yes |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | # Mandatory to randomise namaing for resource group, exadata infra and vmcluster | `number` | `3` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource Group Name | `string` | `"rg-oradb"` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space of the virtual network. e.g. 10.2.0.0/16 | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | n/a | yes |
| <a name="input_vm_cluster_backup_subnet_cidr"></a> [vm\_cluster\_backup\_subnet\_cidr](#input\_vm\_cluster\_backup\_subnet\_cidr) | OCI backup subnet CIDR | `string` | `"192.168.252.0/22"` | no |
| <a name="input_vm_cluster_cpu_core_count"></a> [vm\_cluster\_cpu\_core\_count](#input\_vm\_cluster\_cpu\_core\_count) | The number of CPU cores to enable for the VM cluster. | `number` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_diagnostics_events_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled) | Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_health_monitoring_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled) | Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_incident_logs_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled) | Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_storage_percentage"></a> [vm\_cluster\_data\_storage\_percentage](#input\_vm\_cluster\_data\_storage\_percentage) | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. | `number` | n/a | yes |
| <a name="input_vm_cluster_data_storage_size_in_tbs"></a> [vm\_cluster\_data\_storage\_size\_in\_tbs](#input\_vm\_cluster\_data\_storage\_size\_in\_tbs) | The data disk group size to be allocated in TBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_db_node_storage_size_in_gbs"></a> [vm\_cluster\_db\_node\_storage\_size\_in\_gbs](#input\_vm\_cluster\_db\_node\_storage\_size\_in\_gbs) | The local node storage to be allocated in GBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_gi_version"></a> [vm\_cluster\_gi\_version](#input\_vm\_cluster\_gi\_version) | The Oracle Grid Infrastructure software version for the VM cluster. | `string` | n/a | yes |
| <a name="input_vm_cluster_hostname"></a> [vm\_cluster\_hostname](#input\_vm\_cluster\_hostname) | The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 12 characters minus the random_suffix_length  for Exadata systems | `string` | `"dbServer"` | no |
| <a name="input_vm_cluster_is_local_backup_enabled"></a> [vm\_cluster\_is\_local\_backup\_enabled](#input\_vm\_cluster\_is\_local\_backup\_enabled) | If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster. | `bool` | n/a | yes |
| <a name="input_vm_cluster_is_sparse_diskgroup_enabled"></a> [vm\_cluster\_is\_sparse\_diskgroup\_enabled](#input\_vm\_cluster\_is\_sparse\_diskgroup\_enabled) | If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created. | `bool` | n/a | yes |
| <a name="input_vm_cluster_license_model"></a> [vm\_cluster\_license\_model](#input\_vm\_cluster\_license\_model) | The Oracle license model that applies to the VM clusterAllowed values are: LICENSE\_INCLUDED, BRING\_YOUR\_OWN\_LICENSE | `string` | n/a | yes |
| <a name="input_vm_cluster_memory_size_in_gbs"></a> [vm\_cluster\_memory\_size\_in\_gbs](#input\_vm\_cluster\_memory\_size\_in\_gbs) | The memory to be allocated in GBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | The name of a VM cluster | `string` | n/a | yes |
| <a name="input_vm_cluster_ocpu_count"></a> [vm\_cluster\_ocpu\_count](#input\_vm\_cluster\_ocpu\_count) | The number of OCPU cores to enable on the cloud VM cluster. | `number` | n/a | yes |
| <a name="input_vm_cluster_ssh_public_keys"></a> [vm\_cluster\_ssh\_public\_keys](#input\_vm\_cluster\_ssh\_public\_keys) | The public SSH keys for VM cluster. | `list(string)` | n/a | yes |
| <a name="input_vm_cluster_time_zone"></a> [vm\_cluster\_time\_zone](#input\_vm\_cluster\_time\_zone) | The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exadata_infra"></a> [exadata\_infra](#output\_exadata\_infra) | Resource object of Exadata Infrastructure from Azure |
| <a name="output_vm_cluster"></a> [vm\_cluster](#output\_vm\_cluster) | Resource object of VM Cluster from Azure |
| <a name="output_vm_cluster"></a> [vm\_cluster\_id](#output\_vm\_cluster) | OCID of VM Cluster from Azure for OCI |
| <a name="output_db_home_id"></a> [db\_home\_id](#output\_db\_home\_id) | OCID of Oracle Database Home from OCI |
<!-- END_TF_DOCS -->