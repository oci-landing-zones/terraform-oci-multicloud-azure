# Oracle Database@Azure Exadata VM Cluster

## Summary

Creates an anchor-based Cloud VM Cluster using stable API `2026-06-01`. It reads the selected Network Anchor, infrastructure and DB-server inventory, derives required VNet/subnet IDs, and checks server membership and region/zone/Resource Anchor compatibility. The caller owns anchors, infrastructure, networking and the resource group. Applying allocates paid database compute.

## Requirements

Terraform `>= 1.9, < 2.0` and provider `Azure/azapi ~> 2.0`. Complete Oracle Database@Azure onboarding, register `Oracle.Database`, and grant the caller the required Oracle resource permissions. Configure the provider and authentication in the calling root; this module declares no provider configuration. The Resource Anchor, Network Anchor, infrastructure, VM cluster and networking must share the deployment resource group and subscription, and use one Resource Anchor.

## Usage

Use the repository-relative source below when your root is at the repository root; adjust the path for your project. Copy the module directory with your configuration or use a pinned Git module source, for example `git::https://github.com/oci-landing-zones/terraform-oci-multicloud-azure.git//modules/azapi-ora-exadata-vmc?ref=<release-tag-or-commit>`, after the chosen revision includes this module.

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

module "vm_cluster" {
  source                          = "./modules/azapi-ora-exadata-vmc"
  resource_group_id               = azurerm_resource_group.database.id
  resource_anchor_id              = module.resource_anchor.id
  network_anchor_id               = module.network_anchor.id
  cloud_exadata_infrastructure_id = module.infrastructure.id
  name                            = "oradb-vmcluster"
  location                        = "<azure-region>"
  availability_zone               = "<logical-zone>"
  hostname                        = "oradb"
  gi_version                      = "<available-gi-version>"
  ssh_public_keys                 = [file("<rsa-public-key-path>")]
  cpu_core_count                  = 4
  # Opt in only when the infrastructure is new dedicated capacity in this deployment.
  discover_db_servers = true
  db_server_count     = 2
}
```

The composition example references resources/modules owned by the calling root. Configure its `required_providers` with source `Azure/azapi`; the module inherits its default provider, or pass an alias using `providers = { azapi = azapi.target }`. Initialize, review and apply from that root. Keep state access-controlled and destroy dependent workloads before their anchors or infrastructure.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `resource_group_id` | `Required` | Azure resource group ARM ID that will own this resource. |
| `resource_anchor_id` | `Required` | Existing Resource Anchor ARM ID. |
| `network_anchor_id` | `Required` | Existing Network Anchor ARM ID. |
| `network_ids` | `null` | Optional known `{ subnet_id, vnet_id }` ARM IDs from a Network Anchor's caller-owned resources; verified against the anchor. |
| `cloud_exadata_infrastructure_id` | `Required` | Provisioned Exadata infrastructure ARM ID. Pass the infrastructure module id output to preserve creation ordering. |
| `location` | `Required` | Azure region matching the existing Network Anchor and Exadata capacity. |
| `availability_zone` | `Required` | Azure logical zone matching the Network Anchor and infrastructure. |
| `name` | `"oradb-vmcluster"` | Azure VM cluster resource name and OCI display name. |
| `hostname` | `Required` | VM cluster hostname prefix; use a short unique prefix to leave room for service-generated suffixes. |
| `gi_version` | `Required` | Oracle Grid Infrastructure version available for the region/shape, such as 19.0.0.0. Do not assume the example is currently available. |
| `ssh_public_keys` | `Required` | RSA SSH public keys for cluster access. Supply public keys only, never private key material. |
| `cpu_core_count` | `Required` | CPU cores allocated to the VM cluster. Confirm shape-specific minimum, increment and available capacity. |
| `memory_size_in_gbs` | `256` | Total VM cluster memory allocation in GB across selected DB servers; confirm capacity, divisibility and per-VM sizing. |
| `db_node_storage_size_in_gbs` | `256` | Total local DB node storage allocation in GB across selected DB servers; confirm capacity and supported increments. |
| `data_storage_size_in_tbs` | `2` | DATA disk group allocation in TB; confirm supported minimum and increments. |
| `data_storage_percentage` | `80` | DATA storage percentage; remaining space is RECO. |
| `license_model` | `"BringYourOwnLicense"` | Oracle licensing model using Azure API enum values. |
| `time_zone` | `"UTC"` | Oracle-supported time zone for the VM cluster. |
| `is_local_backup_enabled` | `false` | Enable local Exadata backups. |
| `is_sparse_diskgroup_enabled` | `false` | Enable the SPARSE disk group. |
| `data_collection_options` | `{}` | Oracle diagnostic collection preferences. |
| `db_servers` | `null` | Explicit DB server OCI OCIDs for VM placement (not Azure ARM IDs). Required unless discover_db_servers is explicitly enabled for newly created dedicated infrastructure. |
| `db_server_count` | `2` | Number of DB servers selected automatically when discover_db_servers is enabled; ignored when db_servers is supplied. |
| `discover_db_servers` | `false` | Explicitly allow automatic server selection for newly created dedicated infrastructure only. Keep false for shared or existing infrastructure. |
| `tags` | `{}` | Tags for resources created by this module. |

See [variables.tf](variables.tf) for complete types, validations and object fields.

## Outputs

| Name | Description |
| --- | --- |
| `id` | Cloud VM cluster ARM ID. |
| `ocid` | Cloud VM cluster OCI OCID. |
| `db_server_ocids` | Selected OCI DB server IDs; pin before changing server inventory. |
| `infrastructure_ocid` | Selected Exadata infrastructure OCI OCID. |
| `resource_anchor_id` | Selected Resource Anchor ARM ID. |
| `network_anchor_id` | Selected Network Anchor ARM ID. |

## Lifecycle

Explicit `db_servers` OCI OCIDs are required by default, especially for shared/existing infrastructure. Set `discover_db_servers = true` only for newly created dedicated infrastructure: it selects the first sorted `db_server_count` inventory OCIDs after infrastructure exists. It does not infer free capacity from lifecycle state. After the first apply, persist `db_server_ocids` as the `db_servers` input before any infrastructure edit, including tags. Infrastructure changes can defer inventory reads; automatic selection during those edits can make create-only values unknown and produce a replacement plan. The caller/service must confirm remaining CPU, memory, local storage and placement compatibility. Memory/local-node-storage inputs are cluster totals distributed across selected servers.

Use `cloud_exadata_infrastructure_id = module.infrastructure.id` rather than reconstructing a constant ID for infrastructure created in the same apply. This preserves the dependency for inventory/compatibility reads without broad module dependencies. Read operations remain independent when their inputs are already known. Server/anchor/network/hostname/GI changes are replacement triggers; create/update/delete timeouts are 24 hours. Remove databases and DB homes before replacing/deleting the VM cluster.

When creating a Network Anchor in the same root, optionally pass `network_ids = { subnet_id = azurerm_subnet.oracle.id, vnet_id = azurerm_virtual_network.database.id }` using actual resource outputs. The module checks these IDs against the anchor while keeping immutable payload values known during mutable anchor updates. Leave null when the anchor is reused and its network should be read directly.
