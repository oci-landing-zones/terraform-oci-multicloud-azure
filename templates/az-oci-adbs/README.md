# Terraform Template to setup SSO Federation between OCI & Azure

Terraform Template to step up [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm) This template peforms all steps described in document using Terraform.

Terraform module for **Oracle Autonomous Database Service (ADBS)** , Createss a new Azure virtual network with oracle network attachment subnet and link it to new Autonomous Database resource in Oracle Database @ Azure .

## Providers

| Name                       | Version                                                                                                       |
| -------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [azapi](#provider_azapi)   | n/a                                                                                                           |
| [azurerm](#provider_azapi) | [>=3.99.0](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md#3990-april-11-2024) |

## Modules

| Name                                                 |
| ---------------------------------------------------- |
| [azure-vnet-subnet](../../modules/azure-vnet-subnet) |
| [azure-oracle-adbs](../../modules/azure-oracle-adbs) |

## Inputs Variables

| Name                              | Description                                                                                                                                                                                                                   | Type   | Default           | Required |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ----------------- | :------: |
| `location`                        | Resource region                                                                                                                                                                                                               | string | n/a               |   yes    |
| `resource_group_name`             | Resource group name                                                                                                                                                                                                           | string | n/a               |   yes    |
| `virtual_network_name`            | The name of the virtual network                                                                                                                                                                                               | string | n/a               |   yes    |
| `virtual_network_address_space`   | The address space of the virtual network. e.g. 10.2.0.0/16                                                                                                                                                                    | string | n/a               |   yes    |
| `delegated_subnet_name`           | The name of the delegated subnet.                                                                                                                                                                                             | string | n/a               |   yes    |
| `delegated_subnet_address_prefix` | The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24                                                                                                           | string | n/a               |   yes    |
| `db_name`                         | Database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted                                                                 | string | n/a               |   yes    |
| `db_admin_password`               | Password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (“) or the username “admin”, regardless of casing. | string | n/a               |   yes    |
| `db_ecpu_count`                   | Number of CPU cores to be made available to the database                                                                                                                                                                      | number | 2                 |    no    |
| `db_storage_in_gb`                | Size, in gigabytes, of the data volume that will be created and attached to the database                                                                                                                                      | number | 20                |    no    |
| `db_version`                      | Oracle Database version for Autonomous Database                                                                                                                                                                               | string | "19c"             |          |
| `db_license_model`                | License model either LicenseIncluded or BringYourOwnLicense "                                                                                                                                                                 | string | "LicenseIncluded" |          |
| `db_workload`                     | Autonomous Database workload type                                                                                                                                                                                             | string | "DW"              |          |
| `db_auto_scale_enabled`           | Auto scaling is enabled for the Autonomous Database CPU core count                                                                                                                                                            | bool   | true              |          |
| `db_storage_auto_scale_enabled`   | Auto scaling is enabled for the Autonomous Database storage.                                                                                                                                                                  | bool   | false             |          |
| `db_compute_model`                | Compute model of the Autonomous Database                                                                                                                                                                                      | string | "ECPU"            |          |
| `db_permission_level`             | Autonomous Database permission level. Restricted mode allows access only by admin users                                                                                                                                       | string | "Restricted"      |          |
| `db_type`                         | Database type                                                                                                                                                                                                                 | string | "Regular"         |          |
| `db_character_set`                | Character set for the Autonomous Database                                                                                                                                                                                     | string | "AL32UTF8"        |          |
| `db_n_character_set`              | Character set for the Autonomous Database                                                                                                                                                                                     | string | "AL16UTF16"       |          |

**NOTE:** Autonomous Database resource has lot of parameter combinations and input constraints , please refer to official Oracle docs

- [CreateAutonomousDatabaseBase](https://docs.oracle.com/en-us/iaas/api/#/en/database/20160918/datatypes/CreateAutonomousDatabaseBase)
- [database_autonomous_database](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.2.0/docs/r/database_autonomous_database.html)

## Execution

### Authentication

```
az login --tenant <azure-tenant-id>
```

### Application

Run

```
terraform apply
```

while setting input values either in `terraform.tfvars` file in main.tf directory as

```
location                  = "germanywestcentral"
resource_group            = "tfmrg"
virtual_network_name      = "vnet"
...
```

Or passed as command line parameter

```
terraform apply -var="location=germanywestcentral"  ...
```

### Destruction

```
terraform destroy
```
