# azure-oracle-adbs

## Summary

Terraform module for **Oracle Autonomous Database Serverless (ADB-S)** , Creates a new Autonomous Database resource in Oracle Database @ Azure.

## Pre-requisites

A virtual network with subnet delegated to `Oracle.Database/networkAttachment` present in targetted subscription.

## Providers

| Name      | Version                                                                                                       |
| --------- | ------------------------------------------------------------------------------------------------------------- |
| [azapi]   | n/a                                                                                                           |
| [azurerm] | [>=3.99.0](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md#3990-april-11-2024) |

## Resources

| Name                                                                                                                                               | Type               |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| [autonomousdatabases](https://learn.microsoft.com/en-us/javascript/api/@azure/arm-oracledatabase/autonomousdatabases?view=azure-node-preview)      | azure-node-preview |
| [oci_database_autonomous_database](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.2.0/docs/r/database_autonomous_database.html) | oci resource       |

## Inputs

| Name                            | Description                                                                                                                                                                                                                   | Type   | Default           | Required |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ----------------- | :------: |
| `location`                      | Resource region                                                                                                                                                                                                               |
| `nw_resource_group`             | Virtual network resource group name                                                                                                                                                                                           | string | n/a               |   yes    |
| `nw_vnet_name`                  | Virtual network name                                                                                                                                                                                                          | string | n/a               |   yes    |
| `nw_delegated_subnet_name`      | Oracle delegate subnet name                                                                                                                                                                                                   | string | n/a               |   yes    |
| `db_resource_group`             | ADBS resource group name                                                                                                                                                                                                      | string | n/a               |   yes    |
| `db_name`                       | Database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted                                                                 | string | n/a               |   yes    |
| `db_admin_password`             | Password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (“) or the username “admin”, regardless of casing. | string | n/a               |   yes    |
| `db_ecpu_count`                 | Number of CPU cores to be made available to the database                                                                                                                                                                      | number | 2                 |    no    |
| `db_storage_in_gb`              | Size, in gigabytes, of the data volume that will be created and attached to the database                                                                                                                                      | number | 20                |    no    |
| `db_version`                    | Oracle Database version for Autonomous Database                                                                                                                                                                               | string | "19c"             |          |
| `db_license_model`              | License model either LicenseIncluded or BringYourOwnLicense "                                                                                                                                                                 | string | "LicenseIncluded" |          |
| `db_workload`                   | Autonomous Database workload type                                                                                                                                                                                             | string | "DW"              |          |
| `db_auto_scale_enabled`         | Auto scaling is enabled for the Autonomous Database CPU core count                                                                                                                                                            | bool   | true              |          |
| `db_storage_auto_scale_enabled` | Auto scaling is enabled for the Autonomous Database storage.                                                                                                                                                                  | bool   | false             |          |
| `db_compute_model`              | Compute model of the Autonomous Database                                                                                                                                                                                      | string | "ECPU"            |          |
| `db_permission_level`           | Autonomous Database permission level. Restricted mode allows access only by admin users                                                                                                                                       | string | "Restricted"      |          |
| `db_type`                       | Database type                                                                                                                                                                                                                 | string | "Regular"         |          |
| `db_character_set`              | Character set for the Autonomous Database                                                                                                                                                                                     | string | "AL32UTF8"        |          |
| `db_n_character_set`            | Character set for the Autonomous Database                                                                                                                                                                                     | string | "AL16UTF16"       |          |

**NOTE:** Autonomous Database resource has lot of parameter combinations and input constraints , please refer to official Oracle docs

- [CreateAutonomousDatabaseBase](https://docs.oracle.com/en-us/iaas/api/#/en/database/20160918/datatypes/CreateAutonomousDatabaseBase)
- [database_autonomous_database](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.2.0/docs/r/database_autonomous_database.html)

## Outputs

| Name                     | Description                |
| ------------------------ | -------------------------- |
| autonomous_db_id         | Azure id of created ADBS   |
| autonomous_db_ocid       | OCI id of created ADBS     |
| autonomous_db_properties | Properties of created ADBS |
