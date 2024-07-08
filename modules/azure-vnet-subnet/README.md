# azure-vnet-subnet
## Summary

Terraform module for Azure Network resources creation.


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

| Name                                                                                                            | Type |
|-----------------------------------------------------------------------------------------------------------------|------|
| [azurerm_virtual_network.virtual-network"](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subnet.delegated-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)          | resource |

## Inputs

| Name                                                                                                  | Description                                                                                                         | Type | Default | Required |
|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)             | The name of Azure resource group                                                                                    | `string` | n/a | yes |
| <a name="location"></a> [location](#input\_location)                                                  | The location of the network resources.                                                                              | `string` | n/a | yes |
| <a name="virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network                                                                                     | `string` | n/a | yes |
| virtual_network_address_space | The address space of the virtual network. e.g. 10.2.0.0/16                                                          | `string` | n/a | yes |
| delegated_subnet_address_prefix| The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.2.1.0/24 | `string` | n/a | yes |
| delegated_subnet_name| The name of the delegated subnet.                                                                                   | `string` | n/a | yes |


## Outputs

| Name                                                                                   | Description |
|----------------------------------------------------------------------------------------|-------------|
| <a name="virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id)   | ----------------------------------------------------------------------------- Budget Output ----------------------------------------------------------------------------- |
| <a name="delegated_subnet_id"></a> [delegated\_subnet\_id](#output\_delegated\_subnet\_id) | ----------------------------------------------------------------------------- Budget Output ----------------------------------------------------------------------------- |


# License

Copyright (c) 2022,2023 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](../../LICENSE) for more details.