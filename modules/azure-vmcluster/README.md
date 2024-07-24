# azure-vmcluster

## Summary

Terraform module for Oracle Database @ Azure VM Cluster creation.

## Requirements

Please make sure Oracle Exadata infrastructure cluster, Vnet & deligated subnet for oracle network link exists.

## Providers

| Name  | Version |
| ----- | ------- |
| azapi | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                 | Type     |
| ---------------------------------------------------------------------------------------------------- | -------- |
| [azapi_resource.cloudVmCluster](https://docs.oracle.com/en-us/iaas/odaaz/odaaz-using-terraform.html) | resource |

## Inputs

| Name                                                             | Description                                                                                                                                                                                                                                                                                                          | Type          | Default | Required |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------- | :------: |
| location                                                         | The location of the exadata infrastructure.                                                                                                                                                                                                                                                                          | `string`      | n/a     |   yes    |
| resource_group_id                                                | The Azure Id of resource group                                                                                                                                                                                                                                                                                       | `string`      | n/a     |   yes    |
| exadata_infrastructure_id                                        | Azure resource id of Oracle Exadata Infrastructure                                                                                                                                                                                                                                                                   | `string`      | n/a     |   yes    |
| exadata_infra_dbserver_ocids                                     | "List of Db servers of exadata infrastructure which VM cluster need to use for configuration. By default all dbServers will be used                                                                                                                                                                                  | `set(string)` | n/a     |   yes    |
| vnet_id                                                          | The Azure id of the virtual network                                                                                                                                                                                                                                                                                  | `string`      | n/a     |   yes    |
| oracle_database_delegated_subnet_id                              | Azure Id of the delegated subnet                                                                                                                                                                                                                                                                                     | `string`      | n/a     |   yes    |
| vm_cluster_resource_name                                         | The resource name of a VM cluster                                                                                                                                                                                                                                                                                    | `string`      | n/a     |   yes    |
| vm_cluster_display_name                                          | The display name of a VM cluster                                                                                                                                                                                                                                                                                     | `string`      | n/a     |   yes    |
| vm_cluster_gi_version                                            | The Oracle Grid Infrastructure software version for the VM cluster.                                                                                                                                                                                                                                                  | `string`      | n/a     |   yes    |
| vm_cluster_hostname                                              | The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems.                      | `string`      | n/a     |   yes    |
| vm_cluster_cpu_core_count                                        | "The number of CPU cores to enable for the VM cluster.                                                                                                                                                                                                                                                               | `number`      | n/a     |   yes    |
| vm_cluster_data_collection_options_is_diagnostics_events_enabled | Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues.                                                                                                             | `bool`        | n/a     |   yes    |
| vm_cluster_data_collection_options_is_health_monitoring_enabled  | Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel.                                                                                        | `bool`        | n/a     |   yes    |
| vm_cluster_data_collection_options_is_incident_logs_enabled      | Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. | `bool`        | n/a     |   yes    |
| vm_cluster_data_storage_percentage                               | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80.                                                                                | `number`      | n/a     |   yes    |
| vm_cluster_data_storage_size_in_tbs                              | The data disk group size to be allocated in TBs.                                                                                                                                                                                                                                                                     | `string`      | n/a     |   yes    |
| vm_cluster_db_node_storage_size_in_gbs                           | The local node storage to be allocated in GBs.                                                                                                                                                                                                                                                                       | `string`      | n/a     |   yes    |
| vm_cluster_license_model                                         | The Oracle license model that applies to the VM clusterAllowed values are: LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE                                                                                                                                                                                                  | `string`      | n/a     |   yes    |
| vm_cluster_memory_size_in_gbs                                    | The memory to be allocated in GBs.                                                                                                                                                                                                                                                                                   | `number`      | n/a     |   yes    |
| vm_cluster_time_zone                                             | The time zone to use for the VM cluster. For details, see [database doc timezones](https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html)                                                                                                                                                       | `string`      | n/a     |   yes    |
| vm_cluster_is_local_backup_enabled                               | If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster.                                                                                                                                           | `bool`        | n/a     |   yes    |
| vm_cluster_is_sparse_diskgroup_enabled                           | If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created.                                                                                                                                                                                                     | `bool`        | n/a     |   yes    |
| vm_cluster_ssh_public_key                                        | The public SSH key for VM cluster                                                                                                                                                                                                                                                                                    | `string`      | n/a     |   yes    |

## Outputs

| Name            | Description        |
| --------------- | ------------------ |
| vm_cluster_ocid | OCID of VM Cluster |

# License

See [LICENSE](../../LICENSE) for more details.
