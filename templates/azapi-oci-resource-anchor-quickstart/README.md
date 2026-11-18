# Quickstart Oracle Database@Azure Resource Anchor with AzAPI

## Summary

Terraform template for provisioning an Oracle Database@Azure Resource Anchor, which maps an Azure resource group to an OCI compartment. The template creates an Azure resource group or uses an existing group. Resource Anchors use the Azure ARM location `global`; `location` selects the region of a new resource group.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.9, < 2.0 |
| Azure CLI | Supported version for authentication |

Complete [Oracle Database@Azure onboarding](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/onboard-service.htm), offer acceptance, OCI account linking and consent. The subscription must have `Oracle.Database` registered. Your identity needs permission to manage Resource Anchors and read the selected resource group, plus resource-group creation permission when creating one. Providers do not register resource providers automatically.

Check the target resource group for an existing Resource Anchor before creating another. This template creates a new anchor; import an existing anchor before managing it with this configuration. Manage each resource from only one Terraform state.

## Providers

| Name | Version | Purpose |
| --- | --- | --- |
| Azure/azapi | ~> 2.0 | Resource Anchor |
| hashicorp/azurerm | ~> 4.0 | Resource group |

## Resources

| Name | Type | Behavior |
| --- | --- | --- |
| `azapi_resource.resource_anchor` | Oracle.Database/resourceAnchors@2025-09-01 | Create Resource Anchor |
| `azurerm_resource_group.this` | Microsoft.Resources/resourceGroups | Optional new resource group |
| `data.azurerm_resource_group.this` | Resource group data source | Read an existing group |

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `subscription_id` | `string` | Required | Onboarded Azure subscription UUID |
| `location` | `string` | Required | Azure region for a new resource group |
| `create_resource_group` | `bool` | `true` | Set false to use the named existing group |
| `resource_group_name` | `string` | `rg-oradb-anchor` | New or existing Azure resource group |
| `resource_anchor_name` | `string` | `oradb-resource-anchor` | 3–24 letters, numbers or hyphens |
| `tags` | `map(string)` | `{}` | Tags for resources created by this template |

## Outputs

| Name | Description |
| --- | --- |
| `resource_anchor_id` | Resource Anchor Azure ARM ID |
| `resource_group_id` | Created or reused resource group Azure ARM ID |

## Usage

1. Authenticate and select the onboarded subscription:

   ```sh
   az login
   az account set --subscription "<subscription-id>"
   az provider show --namespace Oracle.Database --query registrationState -o tsv
   ```

2. Copy the variable template and edit the values:

   ```sh
   cp terraform.tfvars.template terraform.tfvars
   ```

   Set `subscription_id`, `location`, `resource_group_name` and `resource_anchor_name`. Set `create_resource_group = false` to reuse a group. Supply credentials through Azure CLI or provider-supported `ARM_*` environment variables, not variable files.

3. Initialize, review and deploy:

   ```sh
   terraform init
   terraform fmt -check
   terraform validate
   terraform plan -out=deploy.tfplan
   terraform apply deploy.tfplan
   terraform output
   ```

Use access-controlled Terraform state and plan storage; retain the generated provider lock file for repeatable provider selection. Do not commit private inputs, credentials or state.

To adopt an existing anchor, configure matching inputs and import it before planning:

```sh
terraform import azapi_resource.resource_anchor "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Oracle.Database/resourceAnchors/<anchor-name>?api-version=2025-09-01"
terraform plan
```

Use `resource_anchor_id` in the [Network Anchor template](../azapi-oci-network-anchor-quickstart) as `existing_resource_anchor_id`, with the same subscription and group and `create_resource_group = false`. The [Exadata template](../azapi-oci-exadata-quickstart) accepts this ID as `resource_anchor_id` together with the Network Anchor ID.

## Cleanup

Remove dependent databases and Network Anchors before deleting the Resource Anchor. Review the destroy plan, including deletion of a resource group created by this template:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

An existing resource group is retained. Remove resources managed by other deployments from a newly created group before destroying it.

See [Oracle anchor design](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-anchor-design.htm) and the [Resource Anchor API reference](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2025-09-01/resourceanchors).
