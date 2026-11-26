# Oracle Database@Azure Exadata Infrastructure

## Summary

Creates dedicated Exadata infrastructure associated with a Resource Anchor using stable API `2026-06-01`. The caller owns the resource group and confirms capacity, shape availability, placement and licensing. Applying allocates paid dedicated capacity.

## Requirements

Terraform `>= 1.9, < 2.0` and provider `Azure/azapi ~> 2.0`. Complete Oracle Database@Azure onboarding, register `Oracle.Database`, and grant the caller the required Oracle resource permissions. Configure the provider and authentication in the calling root; this module declares no provider configuration. The Resource Anchor must share the infrastructure resource group and subscription.

## Usage

Use the repository-relative source below when your root is at the repository root; adjust the path for your project. Copy the module directory with your configuration or use a pinned Git module source, for example `git::https://github.com/oci-landing-zones/terraform-oci-multicloud-azure.git//modules/azapi-ora-exadata-infra?ref=<release-tag-or-commit>`, after the chosen revision includes this module.

```hcl
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azapi" {
  # Configure authentication/subscription in your root, for example via ARM_*.
  skip_provider_registration = true
}

module "infrastructure" {
  source             = "./modules/azapi-ora-exadata-infra"
  resource_group_id  = azurerm_resource_group.database.id
  resource_anchor_id = module.resource_anchor.id
  name               = "oradb-infra"
  shape              = "<available-exadata-shape>"
  location           = "<azure-region>"
  availability_zone  = "<logical-zone>"
  compute_count      = 2
  storage_count      = 3
}
```

The composition example references resources/modules owned by the calling root. Configure its `required_providers` with source `Azure/azapi`; the module inherits its default provider, or pass an alias using `providers = { azapi = azapi.target }`. Initialize, review and apply from that root. Keep state access-controlled and destroy dependent workloads before their anchors or infrastructure.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `resource_group_id` | `Required` | Azure resource group ARM ID that will own this resource. |
| `resource_anchor_id` | `Required` | Existing Resource Anchor ARM ID in the infrastructure resource group and subscription. |
| `location` | `Required` | Azure region matching the existing Network Anchor and Exadata capacity. |
| `availability_zone` | `Required` | Azure logical zone matching the Network Anchor and infrastructure. |
| `name` | `"oradb-infra"` | Azure Exadata infrastructure resource name and OCI display name. |
| `shape` | `Required` | Available Exadata dedicated hardware shape, for example Exadata.X9M. |
| `database_server_type` | `null` | Database server type from target-region flexComponents metadata; required for X11M-family shapes. |
| `storage_server_type` | `null` | Storage server type from target-region flexComponents metadata; required for X11M-family shapes. |
| `compute_count` | `2` | Number of compute servers for new dedicated infrastructure. |
| `storage_count` | `3` | Number of storage servers for new dedicated infrastructure. |
| `tags` | `{}` | Tags for resources created by this module. |

See [variables.tf](variables.tf) for complete types, validations and object fields.

## Outputs

| Name | Description |
| --- | --- |
| `id` | Exadata infrastructure ARM ID; preserves the provisioning dependency for downstream modules. |
| `ocid` | Exadata infrastructure OCI OCID. |

## Lifecycle

Shape, zone and Resource Anchor changes trigger replacement. New infrastructure uses rolling patching with an unrestricted maintenance window. Create/update/delete timeouts are 24 hours. Remove dependent VM clusters before infrastructure deletion. Pass this module's `id` output to dependent modules so Terraform waits for infrastructure provisioning.

For `Exadata.X11M` and `Exadata.X11MV`, supply both server types from the target subscription/region flexComponents metadata. Older shapes omit these properties when the inputs are null. Changing server types replaces the infrastructure.
