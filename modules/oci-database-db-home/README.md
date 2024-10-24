# oci-database-db-home

## Summary
Terraform module for creating [Oracle Database Home](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_db_home) and Container Database (CDB) with default pluggable database (PDB) in a given Exadata VM Cluster

<!-- BEGIN_TF_DOCS -->
## Requirements

- A VM Cluster on Exadata Infrastructure

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_database_db_home.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_db_home) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_db_home"></a> [database\_db\_home](#input\_database\_db\_home) | n/a | <pre>map(object({<br/>    admin_password   = string<br/>    defined_tags     = optional(map(string))<br/>    freeform_tags    = optional(map(string))<br/>    vm_cluster_id    = string<br/>    db_home_version  = string<br/>    db_home_name     = string<br/>    db_home_source   = string<br/>    db_name          = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_db_home"></a> [database\_db\_home](#output\_database\_db\_home) | Database DB HOME informations. |
| <a name="output_db_home_id"></a> [db\_home\_id](#output\_db\_home\_id) | OCID of DB Home |
| <a name="output_db_system_id"></a> [db\_system\_id](#output\_db\_system\_id) | OCID of DB System |
<!-- END_TF_DOCS -->