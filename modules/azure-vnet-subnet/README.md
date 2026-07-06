# azure-vnet-subnet

Creates an Azure virtual network with subnets for Oracle Database@Azure.

If `subnets` is not provided, the module creates one delegated subnet named by `delegated_subnet_name` using the `Oracle.Database/networkAttachments` service delegation required by Oracle Database@Azure VM clusters.

## Inputs

| Name | Description |
|------|-------------|
| `location` | Azure region where the virtual network should exist. |
| `name` | Virtual network name. |
| `resource_group_name` | Azure resource group name. |
| `address_space` | List of address prefixes for the virtual network. |
| `virtual_network_address_space` | Single address prefix used when `address_space` is not provided. |
| `subnets` | Optional subnet map passed to `Azure/avm-res-network-virtualnetwork/azurerm`. |
| `delegated_subnet_name` | Delegated subnet name used when `subnets` is not provided. |
| `delegated_subnet_address_prefix` | Delegated subnet address prefix used when `subnets` is not provided. |
| `tags` | Tags assigned to the virtual network. |

## Outputs

| Name | Description |
|------|-------------|
| `resource_id` | Azure resource ID of the virtual network. |
| `resource_group_name` | Azure resource group where the virtual network exists. |
| `resource` | Virtual network resource object. |
| `subnets` | Subnet outputs from the Azure Verified Module. |
