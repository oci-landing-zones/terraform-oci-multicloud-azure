# azure-connectivity-validation
## Summary

Terraform module for CDB/PDB connectivity test.


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                        | Version |
|-------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name                                                                                                                      | Type |
|---------------------------------------------------------------------------------------------------------------------------|------|
| [null_resource"](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)                   | resource |

## Inputs

| Name                                                                                                      | Description                                                                                                         | Type | Default | Required |
|-----------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="vm_public_ip_address"></a> [vm_public_ip_address](#input\_vm\_public\_ip\_address)               | Virtual machine public IP address.                                                                                  | `string` | n/a | yes |
| <a name="ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key)                                      | SSH private key use to connect to VM.                                                                               | `string` | n/a | yes |
| <a name="cdb_long_connection_string"></a> [virtual\_network\_name](#input\_cdb\_long\_connection\_string) | CDB long connection string.                                                                                         | `string` | n/a | yes |
| <a name="pdb_long_connection_string"></a> [virtual\_network\_name](#input\_pdb\_long\_connection\_string) | PDB long connection string.                                                                                         | `string` | n/a | yes |
| <a name="db_admin_password"></a> [virtual\_network\_name](#input\_db\_admin\_password)                    | Database Administrator password. | `string` | n/a | yes |

# License

Copyright (c) 2022,2023 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](../../LICENSE) for more details.
