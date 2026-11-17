# Quickstart Oracle Database@Azure Resource Anchor with AzAPI

This standalone Terraform template creates an Oracle Database@Azure Resource Anchor with the AzAPI v2 provider and the stable `2025-09-01` Oracle.Database API. A Resource Anchor maps an Azure resource group to an OCI compartment and can be reused by Network Anchors in that group. Resource Anchors are global resources replicated across regions; the Azure ARM resource uses `location = "global"`. The `location` input selects the region of a new Azure resource group.

The template creates:

- An Azure resource group, or references an existing one.
- An Oracle Database@Azure Resource Anchor in that resource group.

Oracle resources use AzAPI; the optional resource group uses AzureRM. No OCI credentials or local modules are required. For networking, use the companion [Network Anchor quickstart](../azapi-oci-network-anchor-quickstart), which can reuse this template's output.

## Prerequisites

1. Terraform `>= 1.9, < 2.0`, Azure CLI, and access to download the `Azure/azapi` 2.x and `hashicorp/azurerm` 4.x providers.
2. Complete [Oracle Database@Azure onboarding](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/onboard-service.htm), including the applicable offer, OCI account linking, consent, and service permissions. Creating a Resource Anchor does not replace onboarding.
3. Use an onboarded subscription. Choose the Azure resource group region using the `location` input; the Resource Anchor itself always uses the `global` ARM location. Resource Anchors are not availability-zone scoped and do not require a zone input.
4. Your identity needs permission to create/read/delete `Oracle.Database/resourceAnchors`, plus resource-group read permission and creation permission if creating a group. Follow your organization's Oracle Database@Azure RBAC requirements. The `Oracle.Database` resource provider must already be registered. Registration requires subscription-level permission; neither provider in this template registers providers automatically.
5. Check the target resource group for an existing Resource Anchor before creating another. This template manages a new anchor; it does not discover or adopt an existing anchor automatically. Use a separate Terraform state for each independent deployment.

See Oracle's [anchor design](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-anchor-design.htm) and the [Resource Anchor API reference](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2025-09-01/resourceanchors).

## Authenticate and deploy

Run from this directory, or copy this directory on its own:

```sh
az login
az account set --subscription "<subscription-id>"
az provider show --namespace Oracle.Database --query registrationState -o tsv
# Ask your subscription administrator if the result is not Registered.

cp terraform.tfvars.example terraform.tfvars
# Edit subscription_id, location, resource-group and anchor settings.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output resource_anchor_id
```

Both providers use `subscription_id` and support Azure CLI authentication. For unattended deployments, configure supported service principal or workload identity credentials using the providers' `ARM_*` environment variables. Do not put credentials in `.tfvars` files. Refer to [AzAPI authentication](https://registry.terraform.io/providers/Azure/azapi/latest/docs) and [AzureRM authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

Store Terraform state and saved plans securely. Use an access-controlled remote backend for shared/customer deployments and retain the generated dependency lock file for reproducible provider selection.

## Use an existing resource group

Set these values in `terraform.tfvars`:

```hcl
subscription_id       = "00000000-0000-0000-0000-000000000000"
location              = "eastus"
create_resource_group = false
resource_group_name   = "rg-oradb-existing"
resource_anchor_name  = "oradb-resource-anchor"
```

Terraform references the group without managing its settings or tags. It creates and manages the Resource Anchor inside the group. If the anchor already exists and you intend to manage it in this configuration, import it into this deployment's state before planning:

```sh
terraform import azapi_resource.resource_anchor "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Oracle.Database/resourceAnchors/<anchor-name>?api-version=2025-09-01"
terraform plan
```

Do not manage the same anchor from multiple Terraform states. Confirm that the configuration matches the imported resource before applying changes.

## Create a Network Anchor using this Resource Anchor

Read the resulting ID:

```sh
terraform output -raw resource_anchor_id
```

In the [Network Anchor quickstart](../azapi-oci-network-anchor-quickstart), use the same subscription and resource group, and set:

```hcl
subscription_id              = "00000000-0000-0000-0000-000000000000"
location                     = "eastus"
availability_zone            = "1" # Confirm a supported database zone for your subscription.
create_resource_group        = false
resource_group_name          = "rg-oradb-anchor"
existing_resource_anchor_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-anchor/providers/Oracle.Database/resourceAnchors/oradb-resource-anchor"
```

Replace the example ID with `resource_anchor_id` from this template. Configure the Network Anchor's networking, capacity and DNS inputs separately. The Network Anchor template references this anchor; its Terraform state does not own it. Keep this Resource Anchor deployed until all dependent Network Anchors and database resources have been removed.

## Inputs and outputs

| Input | Default | Purpose |
| --- | --- | --- |
| `subscription_id` | Required | Onboarded Azure subscription UUID |
| `location` | Required | Azure region for a new resource group |
| `create_resource_group` | `true` | Create or reuse the named group |
| `resource_group_name` | `rg-oradb-anchor` | Group mapped to the OCI compartment |
| `resource_anchor_name` | `oradb-resource-anchor` | Name of the Resource Anchor to create |
| `tags` | `{}` | Tags on the Resource Anchor and any new resource group |

Outputs are `resource_anchor_id` and `resource_group_id`. Both are Azure ARM IDs, not OCI OCIDs. Resource Anchor names contain 3–24 letters, numbers or hyphens.

## Cleanup and local checks

Remove dependent database resources and Network Anchors before deleting this Resource Anchor. Review the destroy plan, including deletion of the resource group if this template created it:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

A reused resource group is left in place. A resource group created by this template belongs to this state; review and remove resources managed by other deployments before destroying it.

The mock-provider tests exercise new/existing resource-group plans and invalid inputs without Azure credentials or cloud changes:

```sh
terraform init -backend=false
terraform fmt -check
terraform validate
terraform test
```

Mock plans do not verify onboarding, service permissions, existing-anchor conflicts, or a live deployment.
