# oci-db-home-cdb-pdb
## Summary

Terraform module for creating Database Home, Database, Pluggable Database for VM Cluster


<!-- BEGIN_TF_DOCS -->
## Requirements

Please make sure [a VM Cluster](../azure-exainfra-vmcluster) has been applied.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_database_db_home](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_db_home) | resource |


## Inputs

| Name                                                                                           | Description                                                     | Type | Default | Required |
|------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|------|---------|:--------:|
| <a name="vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid)                  | The OCID of the VM Cluster                                      | `string` | n/a     |   yes    |
| <a name="db_home_display_name"></a> [db\_home\_display\_name](#input\_db\_home\_display\_name) | The display name of the DB Home                                 | `string` | n/a     |   yes    |
| <a name="db_admin_password"></a> [db\_admin\_password](#input\_db\_admin\_password)            | The database admin password with alphanumerical characters only | `string` | n/a     |   yes    |
| <a name="db_name"></a> [db\_name](#input\_db\_name)                      | The name of the database                                        | `string` | n/a     |   yes    |
| <a name="pdb_name"></a> [pdb\_name](#input\_pdb\_name)              | The name of the pluggable database                              | `string` | n/a     |   yes    |
| <a name="region"></a> [region](#input\_region)           | The region name on the OCI, e.g. us-ashburn-1                   | `string` | n/a     |   yes    |
| db_home_source    | The source of database. For Exadata VM Cluster, use VM_CLUSTER_NEW                                                            | `string` | n/a     |   yes    |
| db_version    | A valid Oracle Database version. e.g. 19.20.0.0                                                            | `string` | n/a     |   yes    |
| db_source    | The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup.                                                             | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                          | Description                |
|-----------------------------------------------------------------------------------------------|----------------------------|
| <a name="cdb_connection_string"></a> [cdb\_connection\_string](#output\cdb\_connection\_string)  | CDB long connection string |
| <a name="pdb_connection_string"></a> [pdb\_connection\_string](#output\pdb\_connection\_string) | PDB long connection string |


# License

Copyright (c) 2022,2023 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](../../LICENSE) for more details.