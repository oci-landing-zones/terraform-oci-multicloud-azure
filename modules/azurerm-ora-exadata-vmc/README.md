# azurerm-ora-exadata-vmc

## Summary

Terraform module for Oracle Database @ Azure Exadata VM Cluster (using AzureRM Terraform Provider)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_oracle_cloud_vm_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/oracle_cloud_vm_cluster) | resource |
| [time_sleep.wait_10s](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_oracle_cloud_vm_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/oracle_cloud_vm_cluster) | data source |
| [azurerm_oracle_db_servers.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/oracle_db_servers) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_subnet_cidr"></a> [backup\_subnet\_cidr](#input\_backup\_subnet\_cidr) | The backup subnet CIDR of the Virtual Network associated with the Cloud VM Cluster. | `string` | `null` | no |
| <a name="input_cloud_exadata_infrastructure_id"></a> [cloud\_exadata\_infrastructure\_id](#input\_cloud\_exadata\_infrastructure\_id) | The OCID of the Cloud Exadata infrastructure. | `string` | n/a | yes |
| <a name="input_cloud_exadata_infrastructure_name"></a> [cloud\_exadata\_infrastructure\_name](#input\_cloud\_exadata\_infrastructure\_name) | The name of the Cloud Exadata infrastructure. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The cluster name for cloud VM cluster. The cluster name must begin with an alphabetic character, and may contain hyphens (-). Underscores (\_) are not permitted. The cluster name can be no longer than 11 characters and is not case sensitive. | `string` | `null` | no |
| <a name="input_cpu_core_count"></a> [cpu\_core\_count](#input\_cpu\_core\_count) | The number of CPU cores enabled on the Cloud VM Cluster. | `string` | n/a | yes |
| <a name="input_data_storage_percentage"></a> [data\_storage\_percentage](#input\_data\_storage\_percentage) | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. | `number` | `null` | no |
| <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs) | The data disk group size to be allocated in TBs. | `number` | `null` | no |
| <a name="input_dbnode_storage_size_in_gbs"></a> [dbnode\_storage\_size\_in\_gbs](#input\_dbnode\_storage\_size\_in\_gbs) | The local node storage to be allocated in GBs. | `number` | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The name of the existing OCI Private DNS Zone to be associated with the Cloud VM Cluster. This allow you to specify your own private domain name instead of the default OCI DNS zone (oraclevcn.com) | `string` | `""` | no |
| <a name="input_gi_version"></a> [gi\_version](#input\_gi\_version) | A valid Oracle Grid Infrastructure (GI) software version. | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The prefix forms the first portion of the Exadata VM Cluster host name. Recommended maximum: 12 characters. | `string` | `null` | no |
| <a name="input_is_diagnostic_events_enabled"></a> [is\_diagnostic\_events\_enabled](#input\_is\_diagnostic\_events\_enabled) | Indicates whether diagnostic collection is enabled for the Cloud VM Cluster. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. Diagnostic collection also allows Oracle to provide enhanced service and proactive support for your Exadata system. You can enable diagnostic collection during VM Cluster/Cloud VM Cluster provisioning. | `bool` | `false` | no |
| <a name="input_is_health_monitoring_enabled"></a> [is\_health\_monitoring\_enabled](#input\_is\_health\_monitoring\_enabled) | Indicates whether health monitoring is enabled for the Cloud VM Cluster. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. You may also receive notifications for some events. Collecting health diagnostics enables Oracle to provide proactive support and enhanced service for your system. Optionally enable health monitoring while provisioning a system. | `bool` | `false` | no |
| <a name="input_is_incident_logs_enabled"></a> [is\_incident\_logs\_enabled](#input\_is\_incident\_logs\_enabled) | Indicates whether incident logs and trace collection are enabled for the Cloud VM Cluster. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. Optionally enable incident logs collection while provisioning a system. | `bool` | `false` | no |
| <a name="input_is_local_backup_enabled"></a> [is\_local\_backup\_enabled](#input\_is\_local\_backup\_enabled) | If true, database backup on local Exadata storage is configured for the Cloud VM Cluster. If false, database backup on local Exadata storage is not available in the Cloud VM Cluster. | `bool` | `null` | no |
| <a name="input_is_sparse_diskgroup_enabled"></a> [is\_sparse\_diskgroup\_enabled](#input\_is\_sparse\_diskgroup\_enabled) | If true, the sparse disk group is configured for the Cloud VM Cluster. If false, the sparse disk group is not created. | `bool` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | The Oracle license model that applies to the Cloud VM Cluster, either BringYourOwnLicense or LicenseIncluded. | `string` | `"LicenseIncluded"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Cloud VM Cluster should exist. | `string` | n/a | yes |
| <a name="input_memory_size_in_gbs"></a> [memory\_size\_in\_gbs](#input\_memory\_size\_in\_gbs) | The memory to be allocated in GBs. | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group where the Cloud VM Cluster should exist | `string` | n/a | yes |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | The public key portion of one or more key pairs used for SSH access to the Cloud VM Cluster. | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet associated with the Cloud VM Cluster. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags which should be assigned to the Cloud VM Cluster. | `map(string)` | `null` | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | The time zone of the Cloud VM Cluster. For details, see Exadata Infrastructure Time Zones. | `string` | `null` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The ID of the Virtual Network associated with the Cloud VM Cluster. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The OCID of the existing OCI Private DNS Zone to be associated with the Cloud VM Cluster. This allow you to specify your own private domain name instead of the default OCI DNS zone (oraclevcn.com) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_compartment_ocid"></a> [oci\_compartment\_ocid](#output\_oci\_compartment\_ocid) | Compartment OCID of the VM Cluster in OCI |
| <a name="output_oci_nsg_ocid"></a> [oci\_nsg\_ocid](#output\_oci\_nsg\_ocid) | OCID of the Network Security Group (NSG) in OCI |
| <a name="output_oci_region"></a> [oci\_region](#output\_oci\_region) | Region of the VM Cluster in OCI |
| <a name="output_oci_vcn_ocid"></a> [oci\_vcn\_ocid](#output\_oci\_vcn\_ocid) | OCID of the Virtual Cloud Network (VCN)in OCI |
| <a name="output_resource"></a> [resource](#output\_resource) | Resource Object of VM Cluster in Azure |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | Resource ID of the VM Cluster in Azure |
| <a name="output_vm_cluster_hostname_actual"></a> [vm\_cluster\_hostname\_actual](#output\_vm\_cluster\_hostname\_actual) | The actual hostname of the VM Cluster after provision |
| <a name="output_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#output\_vm\_cluster\_ocid) | OCID of the VM Cluster in OCI |
<!-- END_TF_DOCS -->