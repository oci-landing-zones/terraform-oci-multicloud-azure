# Oracle Database@Azure Network Anchor

## Summary

Creates a zonal Network Anchor using stable API `2025-09-01`. The caller supplies a Resource Anchor and an existing subnet delegated to `Oracle.Database/networkAttachments`. The Resource Anchor must be in the selected resource group and subscription; this module preserves that supported scope. This module creates no networking or resource group.

## Requirements

Terraform `>= 1.9, < 2.0` and provider `Azure/azapi ~> 2.0`. Complete Oracle Database@Azure onboarding, register `Oracle.Database`, and grant the caller the required Oracle resource permissions. Configure the provider and authentication in the calling root; this module declares no provider configuration. The Resource Anchor and delegated subnet must share the Network Anchor resource group and subscription.

## Usage

Use the repository-relative source below when your root is at the repository root; adjust the path for your project. Copy the module directory with your configuration or use a pinned Git module source, for example `git::https://github.com/oci-landing-zones/terraform-oci-multicloud-azure.git//modules/azapi-ora-network-anchor?ref=<release-tag-or-commit>`, after the chosen revision includes this module.

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

module "network_anchor" {
  source                = "./modules/azapi-ora-network-anchor"
  resource_group_id     = azurerm_resource_group.database.id
  resource_anchor_id    = module.resource_anchor.id
  subnet_id             = azurerm_subnet.oracle.id
  name                  = "oradb-network-anchor"
  location              = "<azure-region>"
  availability_zone     = "<logical-zone>"
  oci_backup_cidr_block = "<non-overlapping-backup-cidr>"
}
```

The composition example references resources/modules owned by the calling root. Configure its `required_providers` with source `Azure/azapi`; the module inherits its default provider, or pass an alias using `providers = { azapi = azapi.target }`. Initialize, review and apply from that root. Keep state access-controlled and destroy dependent workloads before their anchors or infrastructure.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `resource_group_id` | `Required` | Azure resource group ARM ID that will own this resource. |
| `resource_anchor_id` | `Required` | Existing Resource Anchor ARM ID. |
| `subnet_id` | `Required` | Existing delegated subnet in the anchor resource group and subscription. |
| `location` | `Required` | Azure region for the Network Anchor, matching its delegated subnet. |
| `availability_zone` | `Required` | Azure logical availability zone for the Network Anchor. |
| `name` | `"oradb-network-anchor"` | Network Anchor name (3-24 letters, numbers or hyphens). |
| `oci_backup_cidr_block` | `null` | Optional private IPv4 backup CIDR, separate from Azure subnets and connected networks. /24 is recommended; maximum size is /22. Set for an Exadata deployment that requires backup networking. |
| `oci_vcn_dns_label` | `"oradb"` | Requested create-time OCI VCN DNS label; the service can return a canonical VNet-derived label. Set null only when supplying a DNS configuration supported by your database service. |
| `dns` | `{}` | Optional Network Anchor DNS settings. Null flags preserve service defaults. Domain names and listening CIDRs are serialized as comma-separated API strings. Customer DNS resolvers/rules are managed separately. |
| `tags` | `{}` | Tags for resources created by this module. |

See [variables.tf](variables.tf) for complete types, validations and object fields.

## Outputs

| Name | Description |
| --- | --- |
| `id` | Network Anchor ARM ID. |
| `resource_anchor_id` | Selected Resource Anchor ARM ID. |
| `subnet_id` | Selected delegated subnet ARM ID. |

## Lifecycle

Plan non-overlapping private client/backup addressing and capacity before creation. Optional DNS fields are omitted when unset; configure customer DNS resolvers, routes and rules separately. The service can return a canonical VNet-derived DNS label; only this response field is ignored for drift. User changes to create-only inputs still trigger replacement. Remove dependent workloads before replacing/deleting an anchor.
