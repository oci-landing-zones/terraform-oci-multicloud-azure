# azure-vmcluster

## Summary

Terraform module for Oracle Database @ Azure VM Cluster creation.

<!-- BEGIN_TF_DOCS -->
## Requirements

Please make sure Oracle Exadata infrastructure cluster, Vnet & deligated subnet for oracle network link exists.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.cloudVmCluster](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_list.listDbServersByCloudExadataInfrastructure](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_exadata_infra_dbserver_ocids"></a> [exadata\_infra\_dbserver\_ocids](#input\_exadata\_infra\_dbserver\_ocids) | List of Db servers of exadata infrastructure which VM cluster need to use for configuration. By default all dbServers will be used | `set(string)` | `[]` | no |
| <a name="input_exadata_infrastructure_id"></a> [exadata\_infrastructure\_id](#input\_exadata\_infrastructure\_id) | Azure resource id of Oracle Exadata Infrastructure | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the exadata infrastructure. | `string` | n/a | yes |
| <a name="input_nsg_cidrs"></a> [nsg\_cidrs](#input\_nsg\_cidrs) | Add additional Network ingress rules for the VM cluster's network security group. e.g. [{'source': '0.0.0.0/0','destinationPortRange': {'max': 1522,'min': 1521 }}]. | <pre>list(object({<br/>    source = string,<br/>    destinationPortRange = object({<br/>      min = number<br/>      max = number<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_oracle_database_delegated_subnet_id"></a> [oracle\_database\_delegated\_subnet\_id](#input\_oracle\_database\_delegated\_subnet\_id) | Azure Id of the delegated subnet | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The Azure Id of resource group | `string` | n/a | yes |
| <a name="input_vm_cluster_backup_subnet_cidr"></a> [vm\_cluster\_backup\_subnet\_cidr](#input\_vm\_cluster\_backup\_subnet\_cidr) | Client OCI backup subnet CIDR, default is 192.168.252.0/22 | `string` | `"192.168.252.0/22"` | no |
| <a name="input_vm_cluster_cpu_core_count"></a> [vm\_cluster\_cpu\_core\_count](#input\_vm\_cluster\_cpu\_core\_count) | The number of CPU cores to enable for the VM cluster. | `number` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_diagnostics_events_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_diagnostics\_events\_enabled) | Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_health_monitoring_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_health\_monitoring\_enabled) | Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_collection_options_is_incident_logs_enabled"></a> [vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled](#input\_vm\_cluster\_data\_collection\_options\_is\_incident\_logs\_enabled) | Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. | `bool` | n/a | yes |
| <a name="input_vm_cluster_data_storage_percentage"></a> [vm\_cluster\_data\_storage\_percentage](#input\_vm\_cluster\_data\_storage\_percentage) | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. | `number` | n/a | yes |
| <a name="input_vm_cluster_data_storage_size_in_tbs"></a> [vm\_cluster\_data\_storage\_size\_in\_tbs](#input\_vm\_cluster\_data\_storage\_size\_in\_tbs) | The data disk group size to be allocated in TBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_db_node_storage_size_in_gbs"></a> [vm\_cluster\_db\_node\_storage\_size\_in\_gbs](#input\_vm\_cluster\_db\_node\_storage\_size\_in\_gbs) | The local node storage to be allocated in GBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_display_name"></a> [vm\_cluster\_display\_name](#input\_vm\_cluster\_display\_name) | The display name of a VM cluster | `string` | n/a | yes |
| <a name="input_vm_cluster_gi_version"></a> [vm\_cluster\_gi\_version](#input\_vm\_cluster\_gi\_version) | The Oracle Grid Infrastructure software version for the VM cluster. | `string` | n/a | yes |
| <a name="input_vm_cluster_hostname"></a> [vm\_cluster\_hostname](#input\_vm\_cluster\_hostname) | The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems. | `string` | n/a | yes |
| <a name="input_vm_cluster_is_local_backup_enabled"></a> [vm\_cluster\_is\_local\_backup\_enabled](#input\_vm\_cluster\_is\_local\_backup\_enabled) | If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster. | `bool` | n/a | yes |
| <a name="input_vm_cluster_is_sparse_diskgroup_enabled"></a> [vm\_cluster\_is\_sparse\_diskgroup\_enabled](#input\_vm\_cluster\_is\_sparse\_diskgroup\_enabled) | If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created. | `bool` | n/a | yes |
| <a name="input_vm_cluster_license_model"></a> [vm\_cluster\_license\_model](#input\_vm\_cluster\_license\_model) | The Oracle license model that applies to the VM clusterAllowed values are: LICENSE\_INCLUDED, BRING\_YOUR\_OWN\_LICENSE | `string` | n/a | yes |
| <a name="input_vm_cluster_memory_size_in_gbs"></a> [vm\_cluster\_memory\_size\_in\_gbs](#input\_vm\_cluster\_memory\_size\_in\_gbs) | The memory to be allocated in GBs. | `number` | n/a | yes |
| <a name="input_vm_cluster_resource_name"></a> [vm\_cluster\_resource\_name](#input\_vm\_cluster\_resource\_name) | The resource name of a VM cluster | `string` | n/a | yes |
| <a name="input_vm_cluster_scan_listener_port_tcp"></a> [vm\_cluster\_scan\_listener\_port\_tcp](#input\_vm\_cluster\_scan\_listener\_port\_tcp) | The TCP Single Client Access Name (SCAN) port. The default port is 1521. | `number` | `1521` | no |
| <a name="input_vm_cluster_scan_listener_port_tcp_ssl"></a> [vm\_cluster\_scan\_listener\_port\_tcp\_ssl](#input\_vm\_cluster\_scan\_listener\_port\_tcp\_ssl) | The TCPS Single Client Access Name (SCAN) port. The default port is 2484. | `number` | `2484` | no |
| <a name="input_vm_cluster_ssh_public_key"></a> [vm\_cluster\_ssh\_public\_key](#input\_vm\_cluster\_ssh\_public\_key) | The public SSH key for VM cluster. | `string` | n/a | yes |
| <a name="input_vm_cluster_time_zone"></a> [vm\_cluster\_time\_zone](#input\_vm\_cluster\_time\_zone) | The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The Azure id of the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#output\_vm\_cluster\_ocid) | n/a |
<!-- END_TF_DOCS -->