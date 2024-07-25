# azure-virtual-machine
## Summary

Terraform module for Azure Linux Virtual machine resource.


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
| [azurerm_public_ip"](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_public_ip) | resource |
| [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_interface)          | resource |
| [azurerm_linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_linux_virtual_machine)          | resource |
| [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_security_group)          | resource |
| [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_interface_security_group_association)          | resource |
| [azurerm_network_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_security_rule)          | resource |

## Inputs

| Name                                                                                                                                            | Description                                                                                                            | Type | Default | Required |
|-------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="exa_infra_vm_cluster_resource_group"></a> [exa\_infra\_vm\_cluster\_resource\_group](#input\_exa\_infra\_vm\_cluster\_resource\_group) | The name of Exadata Infrastructure and VM Cluster resource group.                                                      | `string` | n/a | yes |
| <a name="location"></a> [location](#input\_location)                                                                                            | The location of the virtual machine resource.                                                                          | `string` | n/a | yes |
| <a name="virtual_machine_name"></a> [virtual\_machine\_name](#input\_virtual\_machine\_name)                                                    | The name of the virtual machine.                                                                                       | `string` | n/a | yes |
| <a name="vm_size"></a> [vm\_size](#input\_vm\_size)                                                                                             | The SKU which should be used for this Virtual Machine, such as Standard_D2s_v3 or Standard_D2as_v4.                    | `string` | n/a | yes |
| <a name="vm_subnet_id"></a> [vm\_subnet\_id](#input\_vm\_subnet\_id)                                                                            | The subnet Id of the virtual machine.                                                                                  | `string` | n/a | yes |
| <a name="ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key)                                                                      | The ssh public key of the virtual machine.                                                                             | `string` | n/a | yes |
| <a name="vm_vnet_resource_group"></a> [vm\_vent\_resource\_group](#input\_vm\_vent\_resource\_group)                                            | The resource group of the VM's virtual network.                                                                        | `string` | n/a | yes |
| <a name="vm_vnet_name"></a> [vm\_vent\_name](#input\_vm\_vent\_name)                                                                            | The virtual network name of the virtual machine.                                                                       | `string` | n/a | yes |
| <a name="vm_vnet_id"></a> [vm\_vent\_id](#input\_vm\_vent\_id)                                                                                  | The virtual network Id of the virtual machine.                                                                         | `string` | n/a | yes |
| <a name="vm_cluster_vnet_id"></a> [vm\_cluster\_vent\_id](#input\_vm\_cluster\_vent\_id)                                                        | The virtual network Id of the VM Cluster.                                                                              | `string` | n/a | yes |
| <a name="vm_cluster_vnet_resource_group"></a> [vm\_cluster\_vent\_resource\_group](#input\_vm\_cluster\_vent\_resource\_group)                  | The resource group of the VM Cluster's virtual network.                                                                | `string` | n/a | yes |
| <a name="vm_cluster_vnet_name"></a> [vm\_cluster\_vent\_name](#input\_vm\_cluster\_vent\_name)                                                  | The virtual network name of the VM Cluster.                                                                            | `string` | n/a | yes |


## Outputs

| Name                                                                                              | Description |
|---------------------------------------------------------------------------------------------------|-------------|
| <a name="vm_public_ip_address"></a> [virtual\_public\_ip\_address](#output\_virtual\_public\_ip\_address) | ----------------------------------------------------------------------------- Budget Output ----------------------------------------------------------------------------- |


# License

Copyright (c) 2022,2023 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](../../LICENSE) for more details.
