# Terraform Template for Provisioning Exa on Azure and Validation

## Providers

| Name | Version |
|------|---------|
| [OCI](https://registry.terraform.io/providers/oracle/oci/latest/docs) | n/a |
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | n/a |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | n/a |

## Modules
| Name                                                               |
|--------------------------------------------------------------------|
| [azure-exainfra-vmcluster](modules/azure-exainfra-vmcluster)    |
| [azure-vnet-subnet](modules/azure-vnet-subnet)                        |
| [oci-db-home-cdb-pdb](oci-db-home-cdb-pdb) |

## Prerequisite
### Terraform
Follow the official doc to install Terraform https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

### Azure CLI
Install Azure CLI, login Azure account, and change to the desired subscription. https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```shell
az login --use-device-code --tenant <TODO: azure tenant id>
```

### OCI CLI
Install OCI CLI in another Terminal and keep the OCI security token being refreshed.
   https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm
```shell
oci session authenticate --region=us-ashburn-1 --tenancy-name=<oci-tenancy-name>
while true; do oci session refresh --profile DEFAULT; sleep 1200; done 
```

### Prepare terraform.tfvars
In the current folder, create a `terraform.tfvars` file, which provides input variables for the Terraform template. 
```shell
# General configuration
region              = "uk-london-1"
location            = "uksouth"
resource_group_name = "OracleDatabaseResourceGroup"
vm_network_resource_group_name = "VMResourceGroup"

# DbHome, CDB, PDB
db_home_display_name = "DBHOME"
db_admin_password    = "Test#123_PASS"
db_name              = "CDB"
pdb_name             = "PDB"
db_home_source       = "VM_CLUSTER_NEW"
db_version           = "19.20.0.0"
db_source            = "NONE"

# Networking Resources
virtual_network_name            = "DatabaseVirtualNetwork"
virtual_network_address_space   = "10.2.0.0/16"
delegated_subnet_address_prefix = "10.2.1.0/24"
delegated_subnet_name           = "delegated"

# Exadata Infra and VM Cluster
exadata_infrastructure_resource_name                             = "ExadataInfrastructure"
exadata_infrastructure_resource_display_name                     = "ExadataInfrastructure"
zones                                                            = "3"
exadata_infrastructure_compute_cpu_count                         = 2
exadata_infrastructure_maintenance_window_lead_time_in_weeks     = 0
exadata_infrastructure_maintenance_window_patching_mode          = "Rolling"
exadata_infrastructure_maintenance_window_preference             = "NoPreference"
exadata_infrastructure_shape                                     = "Exadata.X9M"
exadata_infrastructure_storage_count                             = 3
vm_cluster_cpu_core_count                                        = 4
vm_cluster_data_collection_options_is_diagnostics_events_enabled = true
vm_cluster_data_collection_options_is_health_monitoring_enabled  = true
vm_cluster_data_collection_options_is_incident_logs_enabled      = true
vm_cluster_data_storage_percentage                               = 80
vm_cluster_data_storage_size_in_tbs                              = 2
vm_cluster_db_node_storage_size_in_gbs                           = 120
vm_cluster_gi_version                                            = "19.0.0.0"
vm_cluster_hostname                                              = "host-123"
vm_cluster_is_local_backup_enabled                               = false
vm_cluster_is_sparse_diskgroup_enabled                           = false
vm_cluster_license_model                                         = "LicenseIncluded"
vm_cluster_memory_size_in_gbs                                    = 60
vm_cluster_time_zone                                             = "UTC"
vm_cluster_resource_name                                         = "VMCluster"
vm_cluster_display_name                                          = "VMCluster"
ssh_public_key                                                   ="<TODO: ssh-public-key>"
nsgCidrs = []

# virtual machine
virtual_machine_name             = "VirtualMachine"
vm_vnet_name                     = "VMVirtualNetwork"
vm_virtual_network_address_space = "10.3.0.0/16"
vm_subnet_address_prefix         = "10.3.0.0/24"
ssh_private_key_file             = "<TODO: ssh-private-key-file-path>"
```
Or, you can pass all the variables in the `terraform apply` commend instead.

```
terraform apply -var='region=us-ashburn-1' .....
```

| Name                                                                                                                                 | Description                                                                                                                                                                                                                                                                                                          | Type     | Default                                 | Required |
|--------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|-----------------------------------------|:--------:|
| db_home_display_name                                                                                                                 | The display name of the DB Home                                                                                                                                                                                                                                                                                      | `string` | n/a                                     |   yes    |
| db_admin_password                                                                                                                    | A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -.                                                                               | `string` | n/a                                     |   yes    |
| db_name                                                                                                                              | The database name. The name must begin with an alphabetic character and can contain a maximum of eight alphanumeric characters. Special characters are not permitted.                                                                                                                                                | `string` | n/a                                     |   yes    |
| pdb_name                                                                                                                             | The name of the pluggable database. The name must begin with an alphabetic character and can contain a maximum of thirty alphanumeric characters. Special characters are not permitted. Pluggable database should not be same as database name.                                                                      | `string` | n/a                                     |   yes    |
| region                                                                                                                               | OCI region name. e.g. uk-south-1                                                                                                                                                                                                                                                                                     | `string` | n/a                                     |   yes    |
| location                                                                                                                             | The location of the resources on Azure. e.g. useast                                                                                                                                                                                                                                                                  | `string` | n/a                                     |   yes    |
| virtual_network_name                                                                                                                 | The name of the virtual network                                                                                                                                                                                                                                                                                      | `string` | n/a                                     |   yes    |
| resource_group_name                                                                                                                  | The name of resource group on Azure.                                                                                                                                                                                                                                                                                 | `string` | n/a                                     |   yes    |
| exadata_infrastructure_resource_name                                                                                                 | The name of the Exadata Infrastructure on Azure."                                                                                                                                                                                                                                                                    | `string` | n/a                                     |   yes    |
| exadata_infrastructure_resource_display_name                                                                                         | The display name of the Exadata Infrastructure on OCI.                                                                                                                                                                                                                                                               | `string` | n/a                                     |   yes    |
| zones                                                                                                                                | The zone of the Exadata Infrastructure for Azure.                                                                                                                                                                                                                                                                    | `string` | n/a                                     |   yes    |
| vm_cluster_resource_name                                                                                                             | The resource name of a VM Cluster on Azure.                                                                                                                                                                                                                                                                          | `string` | n/a                                     |   yes    |
| vm_cluster_display_name                                                                                                              | The display name of a VM Cluster on OCI.                                                                                                                                                                                                                                                                             | `string` | n/a                                     |   yes    |
| ssh_public_key                                                                                                                       | The public SSH key for VM Cluster.                                                                                                                                                                                                                                                                                   | `string` | n/a                                     |   yes    |
| db_home_source                                                                                                                       | The source of database. For Exadata VM Cluster, use VM_CLUSTER_NEW                                                                                                                                                                                                                                                   | `string` | n/a                                     |   yes    |
| db_version                                                                                                                           | A valid Oracle Database version. e.g. 19.20.0.0                                                                                                                                                                                                                                                                      | `string` | n/a                                     |   yes    |
| db_source                                                                                                                            | The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup.                                                                                                                                                                              | `string` | n/a                                     |   yes    |
| vm_cluster_cpu_core_count                                                                                                            | The number of CPU cores to enable for the VM cluster                                                                                                                                                                                                                                                                 | `number` | n/a                                     |   yes    |
| vm_cluster_data_collection_options_is_diagnostics_events_enabled                                                                     | Indicates whether diagnostic collection is enabled for the VM cluster/Cloud VM cluster/VMBM DBCS. Enabling diagnostic collection allows you to receive Events service notifications for guest VM issues.                                                                                                             | `bool`   | n/a                                     |   yes    |
| vm_cluster_data_collection_options_is_health_monitoring_enabled                                                                      | Indicates whether health monitoring is enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling health monitoring allows Oracle to collect diagnostic data and share it with its operations and support personnel.                                                                                        | `bool`   | n/a                                     |   yes    |
| vm_cluster_data_collection_options_is_incident_logs_enabled                                                                          | Indicates whether incident logs and trace collection are enabled for the VM cluster / Cloud VM cluster / VMBM DBCS. Enabling incident logs collection allows Oracle to receive Events service notifications for guest VM issues, collect incident logs and traces, and use them to diagnose issues and resolve them. | `bool`   | n/a                                     |   yes    |
| vm_cluster_data_storage_percentage                                                                                                   | The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80.                                                                                | `number` | n/a                                     |   yes    |
| vm_cluster_data_storage_size_in_tbs                                                                                                  | The data disk group size to be allocated in TBs.                                                                                                                                                                                                                                                                     | `number` | n/a                                     |   yes    |
| vm_cluster_db_node_storage_size_in_gbs                                                                                               | The local node storage to be allocated in GBs.                                                                                                                                                                                                                                                                       | `number` | n/a                                     |   yes    |
| vm_cluster_gi_version                                                                                                                | The Oracle Grid Infrastructure software version for the VM cluster.                                                                                                                                                                                                                                                  | `string` | n/a                                     |   yes    |
| vm_cluster_hostname                                                                                                                  | The hostname for the cloud VM Cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems.                      | `string` | n/a                                     |   yes    |
| vm_cluster_license_model                                                                                                             | The Oracle license model that applies to the VM cluster. Allowed values are: LICENSE_INCLUDED, BRING_YOUR_OWN_LICENSE                                                                                                                                                                                                | `string` | n/a                                     |   yes    |
| vm_cluster_memory_size_in_gbs                                                                                                        | The memory to be allocated in GBs                                                                                                                                                                                                                                                                                    | `number` | n/a                                     |   yes    |
| vm_cluster_time_zone                                                                                                                 | The time zone to use for the VM cluster. For details, see https://docs.oracle.com/en-us/iaas/base-database/doc/manage-time-zone.html                                                                                                                                                                                 | `string` | n/a                                     |   yes    |
| vm_cluster_is_local_backup_enabled                                                                                                   | If true, database backup on local Exadata storage is configured for the VM cluster. If false, database backup on local Exadata storage is not available in the VM cluster.                                                                                                                                           | `bool`   | n/a                                     |   yes    |
| vm_cluster_is_sparse_diskgroup_enabled                                                                                               | If true, the sparse disk group is configured for the VM cluster. If false, the sparse disk group is not created.                                                                                                                                                                                                     | `bool`   | n/a                                     |   yes    |
| exadata_infrastructure_compute_cpu_count                                                                                             | The number of compute servers for the cloud Exadata infrastructure.                                                                                                                                                                                                                                                  | `number` | n/a                                     |   yes    |
| exadata_infrastructure_shape                                                                                                         | The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M                                                                                                                                                                                                                                             | `string` | n/a                                     |   yes    |
| exadata_infrastructure_maintenance_window_lead_time_in_weeks                                                                         | Lead time window allows user to set a lead time to prepare for a down time. The lead time is in weeks and valid value is between 1 to 4.                                                                                                                                                                             | `number` | n/a                                     |   yes    |
| exadata_infrastructure_maintenance_window_preference                                                                                 | The maintenance window scheduling preference.Allowed values are: NO_PREFERENCE, CUSTOM_PREFERENCE.                                                                                                                                                                                                                   | `string` | n/a                                     |   yes    |
| exadata_infrastructure_maintenance_window_patching_mode                                                                              | Cloud Exadata infrastructure node patching method, either ROLLING or NONROLLING.                                                                                                                                                                                                                                     | `string` | n/a                                     |   yes    |
| exadata_infrastructure_storage_count                                                                                                 | The number of storage servers for the Exadata infrastructure                                                                                                                                                                                                                                                         | `number` | n/a                                     |   yes    |
| virtual_network_address_space                                                                                                        | The address space of the virtual network. e.g. 10.2.0.0/16                                                                                                                                                                                                                                                           | `string` | n/a                                     |   yes    |
| delegated_subnet_address_prefix                                                                                                      | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24                                                                                                                                                                                                  | `string` | n/a                                     |   yes    || exadata_infrastructure_storage_count                |The display name of the DB Home | `string` | n/a     |   yes    |
| delegated_subnet_name                                                                                                                | The name of the delegated subnet                                                                                                                                                                                                                                                                                     | `string` | n/a                                     |   yes    |
| <a name="nsg_cidrs"></a> [nsg\_cidrs](#input\_nsg\_cidrs)                                                                            | Add additional Network ingress rules for the VM cluster's network security group. e.g. [{source: "0.0.0.0/0",destinationPortRange:{max:1522,min:1521}}].                                                                                                                                                             | `list of objects` | []                                      |    no    |
| <a name="vm_network_resource_group_name"></a> [vm\_network\_resource\_group\_name](#input\_vm\_network\_resource\_group\_name)       | The resource group name of virtual machine network on Azure.                                                                                                                                                                                                                                                         | `string` | n/a                                     |   yes    |
| <a name="vm_virtual_network_address_space"></a> [vm\_virtual\_network\_address\_space](#input\_vm\_virtual\_network\_address\_space) | The address space of the VM's virtual network. e.g. 10.3.0.0/16                                                                                                                                                                                                                                                      | `string` | Exa Infra and VM Cluster resource group |    no    |
| <a name="vm_vnet_name"></a> [vm\_vent\_name](#input\_vm\_vent\_name)                                                                 | The virtual network name of the virtual machine.                                                                                                                                                                                                                                                                     | `string` | VM Cluster resource virtual network.    |    no    |
| <a name="virtual_machine_name"></a> [virtual\_machine\_name](#input\_virtual\_machine\_name)                                         | The name of the virtual machine.                                                                                                                                                                                                                                                                                     | `string` | n/a                                     |   yes    |
| <a name="ssh_private_key_file"></a> [ssh\_private\_key\_file](#input\_ssh\_private\_key\_file)                                                      | The file path to SSH private key use to connect to VM.                                                                                                                                                                                                                                                               | `string` | n/a                                     |   yes    |

# Caveat
when you clean up exa infra and vm cluster resources via `terraform destroy`, you may encounter `EXA_INFRA_DELETE_FAILED` see error like below:
```
│ Error: Failed to delete resource
|
|deleting Resource: ...
│ --------------------------------------------------------------------------------
│ RESPONSE 200: 200 OK
│ ERROR CODE: EXA_INFRA_DELETE_FAILED
│ --------------------------------------------------------------------------------
...
│     "code": "EXA_INFRA_DELETE_FAILED",
│     "message": "Error returned by DeleteCloudExadataInfrastructure operation in Database service.(409, IncorrectState, false) Cannot delete Exadata infrastructure ocid1.cloudexadatainfrastructure.oc1.uk-london-1... for tenant ocid1.tenancy.oc1.... All associated VM clusters must be deleted before you delete the Exadata infrastructure. (opc-request-id: ...)\nTimestamp: 2024-07-18T17:16:12.958Z\n"
```
This is because deleting Vm cluster is still in progress.
Please retry `terraform destroy` after 1hr ~ 1.5hr.