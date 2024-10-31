# Quickstart OracleDB@Azure (Exadata) with OCI LZ modules (AzureRM)

## Summary
This is a Terraform Template for provisioning Oracle Database@Azure with the following resources using AzureRM and OCI Terraform provider

- Azure Resource Group (AzureRM) - Optional
- Azure VNet with a delegated subnet for OracleDB@Azure (AzureRM/AVM)
- Oracle Exadata Infrastructure (AzureRM)
- Oracle VM Cluster (AzureRM)
- OCI Private View (OCI) - Optional
- OCI Private Zone (OCI) - Optional
- Oracle Database Home (OCI)
- Oracle Container Database (OCI)
- Oracle Pluggable Database (OCI)

> [!NOTE]  
> This template involving Azure Verified Modules (AVM) which [require Terraform 1.9](https://github.com/Azure/terraform-azurerm-avm-res-oracledatabase-cloudvmcluster/blob/main/terraform.tf) and does not support OpenTofu (which [support up to Terraform 1.8](https://opentofu.org/docs/intro/migration/terraform-1.8/) at the moment).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.6.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.1 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.15.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.7.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.15.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_network"></a> [avm\_network](#module\_avm\_network) | Azure/avm-res-network-virtualnetwork/azurerm | 0.5.0 |
| <a name="module_azure-resource-grp"></a> [azure-resource-grp](#module\_azure-resource-grp) | ../../modules/azure-resource-grp | n/a |
| <a name="module_azurerm_exadata_infra"></a> [azurerm\_exadata\_infra](#module\_azurerm\_exadata\_infra) | ../../modules/azurerm-ora-exadata-infra | n/a |
| <a name="module_azurerm_exadata_vmc"></a> [azurerm\_exadata\_vmc](#module\_azurerm\_exadata\_vmc) | ../../modules/azurerm-ora-exadata-vmc | n/a |
| <a name="module_oci-database-db-home"></a> [oci-database-db-home](#module\_oci-database-db-home) | ../../modules/oci-database-db-home | n/a |
| <a name="module_oci-network-dns"></a> [oci-network-dns](#module\_oci-network-dns) | ../../modules/oci-network-dns | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_after_deletion](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_subnet.delegated_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [oci_database_databases.cdb](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/database_databases) | data source |
| [oci_database_pluggable_databases.pdb](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/database_pluggable_databases) | data source |
| [oci_dns_zones.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/dns_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avm_enable_telemetry"></a> [avm\_enable\_telemetry](#input\_avm\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the Azure Verified Modules | `bool` | `true` | no |
| <a name="input_az_region"></a> [az\_region](#input\_az\_region) | The location of the resources on Azure. e.g. useast | `string` | n/a | yes |
| <a name="input_az_zone"></a> [az\_zone](#input\_az\_zone) | The zone of the exadata infrastructure | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | resource tags to be used in both Azure and OCI | `map(string)` | n/a | yes |
| <a name="input_db_admin_password"></a> [db\_admin\_password](#input\_db\_admin\_password) | A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be \_, #, or -. | `string` | n/a | yes |
| <a name="input_db_home_name"></a> [db\_home\_name](#input\_db\_home\_name) | The name of the DB Home | `string` | `"dbhome"` | no |
| <a name="input_db_home_source"></a> [db\_home\_source](#input\_db\_home\_source) | The source of database. For Exadata VM Cluster, use VM\_CLUSTER\_NEW | `string` | `"VM_CLUSTER_NEW"` | no |
| <a name="input_db_home_version"></a> [db\_home\_version](#input\_db\_home\_version) | A valid Oracle Database version. e.g. 19.0.0.0 | `string` | `"19.0.0.0"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database | `string` | n/a | yes |
| <a name="input_db_source"></a> [db\_source](#input\_db\_source) | The source of the database: Use NONE for creating a new database. Use DB\_BACKUP for creating a new database by restoring from a backup. | `string` | `"NONE"` | no |
| <a name="input_delegated_subnet_address_prefix"></a> [delegated\_subnet\_address\_prefix](#input\_delegated\_subnet\_address\_prefix) | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24 | `string` | n/a | yes |
| <a name="input_delegated_subnet_name"></a> [delegated\_subnet\_name](#input\_delegated\_subnet\_name) | The name of the delegated subnet | `string` | `"snet-delegate-oci"` | no |
| <a name="input_enable_database_delete"></a> [enable\_database\_delete](#input\_enable\_database\_delete) | Unless enable\_database\_delete is explicitly set to true, Terraform will not delete the database within the Db Home configuration but rather remove it from the config and state file. | `bool` | `false` | no |
| <a name="input_exadata_infrastructure_compute_count"></a> [exadata\_infrastructure\_compute\_count](#input\_exadata\_infrastructure\_compute\_count) | The number of compute servers for the cloud Exadata infrastructure. | `number` | `2` | no |
| <a name="input_exadata_infrastructure_maintenance_window"></a> [exadata\_infrastructure\_maintenance\_window](#input\_exadata\_infrastructure\_maintenance\_window) | maintenanceWindow properties | <pre>object({<br/>      patching_mode = string<br/>      preference = string<br/>      lead_time_in_weeks = optional(number)<br/>      months = optional(list(number))<br/>      weeks_of_month = optional(list(number))<br/>      days_of_week =optional(list(number))<br/>      hours_of_day = optional(list(number))<br/>  })</pre> | <pre>{<br/>  "patching_mode": "Rolling",<br/>  "preference": "NoPreference"<br/>}</pre> | no |
| <a name="input_exadata_infrastructure_name"></a> [exadata\_infrastructure\_name](#input\_exadata\_infrastructure\_name) | The name of the exadata infrastructure on Azure | `string` | `"odaaz-infra"` | no |
| <a name="input_exadata_infrastructure_shape"></a> [exadata\_infrastructure\_shape](#input\_exadata\_infrastructure\_shape) | The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M | `string` | `"Exadata.X9M"` | no |
| <a name="input_exadata_infrastructure_storage_count"></a> [exadata\_infrastructure\_storage\_count](#input\_exadata\_infrastructure\_storage\_count) | The number of storage servers for the Exadata infrastructure. | `number` | `3` | no |
| <a name="input_new_rg"></a> [new\_rg](#input\_new\_rg) | Create new resource group or not | `bool` | `true` | no |
| <a name="input_nsg_cidrs"></a> [nsg\_cidrs](#input\_nsg\_cidrs) | Add additional Network ingress rules for the VM cluster's network security group. e.g. [{'source': '0.0.0.0/0','destinationPortRange': {'max': 1522,'min': 1521 }}]. | <pre>list(object({<br/>    source = string,<br/>    destinationPortRange = object({<br/>      min = number<br/>      max = number<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_oci_config_file_profile"></a> [oci\_config\_file\_profile](#input\_oci\_config\_file\_profile) | OCI Config file name | `string` | `"DEFAULT"` | no |
| <a name="input_oci_fingerprint"></a> [oci\_fingerprint](#input\_oci\_fingerprint) | Fingerprint for the key pair being used | `string` | n/a | yes |
| <a name="input_oci_private_key_password"></a> [oci\_private\_key\_password](#input\_oci\_private\_key\_password) | Passphrase used for the key, if it's encrypted | `string` | `null` | no |
| <a name="input_oci_private_key_path"></a> [oci\_private\_key\_path](#input\_oci\_private\_key\_path) | The path (including filename) of the private key | `string` | n/a | yes |
| <a name="input_oci_tenancy_ocid"></a> [oci\_tenancy\_ocid](#input\_oci\_tenancy\_ocid) | OCID of the OCI tenancy | `string` | n/a | yes |
| <a name="input_oci_user_ocid"></a> [oci\_user\_ocid](#input\_oci\_user\_ocid) | OCID of the OCI user | `string` | n/a | yes |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | # Mandatory to randomise namaing for resource group, exadata infra and vmcluster | `number` | `3` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource Group Name | `string` | `"rg-oradb"` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space of the virtual network. e.g. 10.2.0.0/16 | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `"vnet-oci"` | no |
| <a name="input_vm_cluster_backup_subnet_cidr"></a> [vm\_cluster\_backup\_subnet\_cidr](#input\_vm\_cluster\_backup\_subnet\_cidr) | OCI backup subnet CIDR | `string` | `"192.168.252.0/22"` | no |
| <a name="input_vm_cluster_cpu_core_count"></a> [vm\_cluster\_cpu\_core\_count](#input\_vm\_cluster\_cpu\_core\_count) | The number of CPU cores to enable for the VM cluster. | `number` | `4` | no |
| <a name="input_vm_cluster_data_collection_options_is_diagnostics_events_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled) | Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. | `bool` | `true` | no |
| <a name="input_vm_cluster_data_collection_options_is_health_monitoring_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled) | Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. | `bool` | `true` | no |
| <a name="input_vm_cluster_data_collection_options_is_incident_logs_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled) | Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. | `bool` | `true` | no |
| <a name="input_vm_cluster_data_storage_percentage"></a> [vm\_cluster\_data\_storage\_percentage](#input\_vm\_cluster\_data\_storage\_percentage) | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. | `number` | `80` | no |
| <a name="input_vm_cluster_data_storage_size_in_tbs"></a> [vm\_cluster\_data\_storage\_size\_in\_tbs](#input\_vm\_cluster\_data\_storage\_size\_in\_tbs) | The data disk group size to be allocated in TBs. | `number` | `2` | no |
| <a name="input_vm_cluster_db_node_storage_size_in_gbs"></a> [vm\_cluster\_db\_node\_storage\_size\_in\_gbs](#input\_vm\_cluster\_db\_node\_storage\_size\_in\_gbs) | The local node storage to be allocated in GBs. | `number` | `500` | no |
| <a name="input_vm_cluster_domain"></a> [vm\_cluster\_domain](#input\_vm\_cluster\_domain) | The domain name for the cloud VM cluster. | `string` | `""` | no |
| <a name="input_vm_cluster_gi_version"></a> [vm\_cluster\_gi\_version](#input\_vm\_cluster\_gi\_version) | The Oracle Grid Infrastructure software version for the VM cluster. | `string` | `"19.0.0.0"` | no |
| <a name="input_vm_cluster_hostname"></a> [vm\_cluster\_hostname](#input\_vm\_cluster\_hostname) | The prefix forms the first portion of the Exadata VM Cluster host name. Recommended maximum: 12 characters. | `string` | n/a | yes |
| <a name="input_vm_cluster_is_local_backup_enabled"></a> [vm\_cluster\_is\_local\_backup\_enabled](#input\_vm\_cluster\_is\_local\_backup\_enabled) | If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster. | `bool` | `false` | no |
| <a name="input_vm_cluster_is_sparse_diskgroup_enabled"></a> [vm\_cluster\_is\_sparse\_diskgroup\_enabled](#input\_vm\_cluster\_is\_sparse\_diskgroup\_enabled) | If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created. | `bool` | `false` | no |
| <a name="input_vm_cluster_license_model"></a> [vm\_cluster\_license\_model](#input\_vm\_cluster\_license\_model) | The Oracle license model that applies to the VM clusterAllowed values are: LICENSE\_INCLUDED, BRING\_YOUR\_OWN\_LICENSE | `string` | `"LicenseIncluded"` | no |
| <a name="input_vm_cluster_memory_size_in_gbs"></a> [vm\_cluster\_memory\_size\_in\_gbs](#input\_vm\_cluster\_memory\_size\_in\_gbs) | The memory to be allocated in GBs. | `number` | `60` | no |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | The name of a VM cluster | `string` | n/a | yes |
| <a name="input_vm_cluster_new_oci_dns"></a> [vm\_cluster\_new\_oci\_dns](#input\_vm\_cluster\_new\_oci\_dns) | Create private DNS zone in OCI when custom domain is configured. Set to false for reusing existing DNS zone | `bool` | `true` | no |
| <a name="input_vm_cluster_scan_listener_port_tcp"></a> [vm\_cluster\_scan\_listener\_port\_tcp](#input\_vm\_cluster\_scan\_listener\_port\_tcp) | The TCP Single Client Access Name (SCAN) port. The default port is 1521. | `number` | `1521` | no |
| <a name="input_vm_cluster_scan_listener_port_tcp_ssl"></a> [vm\_cluster\_scan\_listener\_port\_tcp\_ssl](#input\_vm\_cluster\_scan\_listener\_port\_tcp\_ssl) | The TCPS Single Client Access Name (SCAN) port. The default port is 2484. | `number` | `2484` | no |
| <a name="input_vm_cluster_ssh_public_keys"></a> [vm\_cluster\_ssh\_public\_keys](#input\_vm\_cluster\_ssh\_public\_keys) | The public SSH keys for VM cluster. | `list(string)` | n/a | yes |
| <a name="input_vm_cluster_time_zone"></a> [vm\_cluster\_time\_zone](#input\_vm\_cluster\_time\_zone) | The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_az_exadata_infra_id"></a> [az\_exadata\_infra\_id](#output\_az\_exadata\_infra\_id) | Resource ID of Exadata Infrastructure from Azure |
| <a name="output_az_resource_group_name"></a> [az\_resource\_group\_name](#output\_az\_resource\_group\_name) | Name of Resource Group in Azure |
| <a name="output_az_vm_cluster_id"></a> [az\_vm\_cluster\_id](#output\_az\_vm\_cluster\_id) | Resource ID of VM Cluster from Azure |
| <a name="output_az_vnet_id"></a> [az\_vnet\_id](#output\_az\_vnet\_id) | Resource ID of Azure VNet |
| <a name="output_oci_cdb_connection_strings"></a> [oci\_cdb\_connection\_strings](#output\_oci\_cdb\_connection\_strings) | OCID of the Oracle Container Database from OCI |
| <a name="output_oci_cdb_id"></a> [oci\_cdb\_id](#output\_oci\_cdb\_id) | OCID of the Oracle Container Database from OCI |
| <a name="output_oci_cdb_name"></a> [oci\_cdb\_name](#output\_oci\_cdb\_name) | Name of the Oracle Container Database from OCI |
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | OCI Info |
| <a name="output_oci_db_home_id"></a> [oci\_db\_home\_id](#output\_oci\_db\_home\_id) | OCID of Oracle Database Home from OCI |
| <a name="output_oci_nsg_id"></a> [oci\_nsg\_id](#output\_oci\_nsg\_id) | n/a |
| <a name="output_oci_pdb_connection_strings"></a> [oci\_pdb\_connection\_strings](#output\_oci\_pdb\_connection\_strings) | OCID of the Oracle Pluggable Database from OCI |
| <a name="output_oci_pdb_id"></a> [oci\_pdb\_id](#output\_oci\_pdb\_id) | OCID of the Oracle Pluggable Database from OCI |
| <a name="output_oci_pdb_name"></a> [oci\_pdb\_name](#output\_oci\_pdb\_name) | Name of the Oracle Pluggable Database from OCI |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | n/a |
| <a name="output_oci_vcn_id"></a> [oci\_vcn\_id](#output\_oci\_vcn\_id) | n/a |
| <a name="output_oci_vm_cluster_id"></a> [oci\_vm\_cluster\_id](#output\_oci\_vm\_cluster\_id) | OCID of VM Cluster from Azure for OCI |
<!-- END_TF_DOCS -->