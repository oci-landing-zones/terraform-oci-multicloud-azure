# Oracle Database@Azure Resource Anchor

## Summary

Creates a Resource Anchor at ARM location `global` using stable API `2025-09-01`. The caller owns the Azure resource group and Azure authentication.

## Requirements

Terraform `>= 1.9, < 2.0` and provider `Azure/azapi ~> 2.0`. Complete Oracle Database@Azure onboarding, register `Oracle.Database`, and grant the caller the required Oracle resource permissions. Configure the provider and authentication in the calling root; this module declares no provider configuration. IDs must reference the same subscription as `resource_group_id`.

## Usage

Use the repository-relative source below when your root is at the repository root; adjust the path for your project. Copy the module directory with your configuration or use a pinned Git module source, for example `git::https://github.com/oci-landing-zones/terraform-oci-multicloud-azure.git//modules/azapi-ora-resource-anchor?ref=<release-tag-or-commit>`, after the chosen revision includes this module.

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

module "resource_anchor" {
  source            = "./modules/azapi-ora-resource-anchor"
  resource_group_id = azurerm_resource_group.database.id
  name              = "oradb-resource-anchor"
}
```

The composition example references resources/modules owned by the calling root. Configure its `required_providers` with source `Azure/azapi`; the module inherits its default provider, or pass an alias using `providers = { azapi = azapi.target }`. Initialize, review and apply from that root. Keep state access-controlled and destroy dependent workloads before their anchors or infrastructure.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `resource_group_id` | `Required` | Azure resource group ARM ID that will own this resource. |
| `name` | `"oradb-resource-anchor"` | Resource Anchor name (3-24 letters, numbers or hyphens). |
| `tags` | `{}` | Tags for resources created by this module. |

See [variables.tf](variables.tf) for complete types, validations and object fields.

## Outputs

| Name | Description |
| --- | --- |
| `id` | Resource Anchor ARM ID. |

## Lifecycle

Keep the Resource Anchor until its Network Anchors and database workloads have been removed. The resource group is not managed by this module.
