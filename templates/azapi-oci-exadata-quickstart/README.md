# Quickstart Oracle Database@Azure Exadata infrastructure and VM cluster with AzAPI

## Summary

Terraform template for creating Exadata dedicated infrastructure and a Cloud VM Cluster using existing Resource and Network Anchors. The infrastructure receives the Resource Anchor ID; the VM cluster receives both anchor IDs and the infrastructure ID. Required VNet/subnet IDs are read from the Network Anchor, keeping its network configuration consistent with the cluster.

Leave `existing_cloud_exadata_infrastructure_id = null` to create both infrastructure and VM cluster. Supply an existing infrastructure ARM ID to create only a VM cluster on that capacity. Anchors and networking remain owned by their original deployments. This template does not provision DB homes or databases.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.9, < 2.0 |
| Azure CLI | Supported version for authentication |

- Complete Oracle Database@Azure onboarding, offer acceptance, account linking and consent. Register `Oracle.Database` and confirm that Exadata anchor-based provisioning is available for the selected subscription and region. Providers do not register resource providers automatically.
- Create a [Resource Anchor](../azapi-oci-resource-anchor-quickstart), then a [Network Anchor](../azapi-oci-network-anchor-quickstart) associated with it. Configure sufficient client and backup addressing for Exadata before creating the Network Anchor.
- Use the same subscription for resources in this template. Cross-subscription anchor references are outside its scope. The Network Anchor and infrastructure must match the region, Azure logical zone and Resource Anchor. The workload resource group can differ from the anchor groups; ensure appropriate cross-group permissions. Resource Anchors have location `global`.
- Your identity needs permissions to read the anchors, inventory and any existing infrastructure, manage the new Oracle resources, and read or create the workload resource group. Follow your organization's Oracle Database@Azure RBAC requirements.
- Confirm available dedicated capacity, shape, server counts, GI version, per-server sizing and licensing before applying. **Deployment allocates paid Exadata capacity and compute.** Provisioning can take hours; operation timeouts are 24 hours.
- Supply RSA public SSH keys of at least 2048 bits in single-line OpenSSH `ssh-rsa` format. Never supply private keys. Select a short hostname prefix and ensure database DNS names resolve from clients.

## Providers

| Name | Version | Purpose |
| --- | --- | --- |
| Azure/azapi | ~> 2.0 | Exadata infrastructure, VM cluster and anchor/inventory reads |
| hashicorp/azurerm | ~> 4.0 | Resource group |

## Modules

This quickstart composes the reusable modules below. Run it from the repository checkout, or copy its module directories while preserving the `../../modules/` layout. If adapting the template to your own project, update the module `source` paths or use a pinned Git module source. Copying the template directory alone is insufficient.

| Module | Source |
| --- | --- |
| `infrastructure` | [azapi-ora-exadata-infra](../../modules/azapi-ora-exadata-infra) |
| `vm_cluster` | [azapi-ora-exadata-vmc](../../modules/azapi-ora-exadata-vmc) |

## Resources

| Name | Type | Behavior |
| --- | --- | --- |
| `module.infrastructure[0].azapi_resource.this` | Oracle.Database/cloudExadataInfrastructures@2026-06-01 | Optional new Exadata infrastructure |
| `module.vm_cluster.azapi_resource.this` | Oracle.Database/cloudVmClusters@2026-06-01 | New VM cluster |
| `azurerm_resource_group.this` | Resource group | Optional new workload group |
| `data.azurerm_resource_group.this` | Resource group data source | Read existing workload group |
| `module.vm_cluster.data.azapi_resource.network_anchor` | Network Anchor data source | Read network and anchor association |
| `module.vm_cluster.data.azapi_resource.infrastructure` | Exadata infrastructure data source | Read selected new or existing capacity |
| `module.vm_cluster.data.azapi_resource_list.db_servers` | Exadata DB server inventory | Discover OCI DB server IDs |

The stable `2026-06-01` API exposes Exadata anchor properties; `2025-09-01` does not expose them on these two resources. Infrastructure uses Azure `zones`. The VM cluster derives placement from infrastructure and the Network Anchor; its optional `zoneId` is an OCI DNS zone OCID, not an Azure logical zone.

## Inputs

| Input | Default | Purpose |
| --- | --- | --- |
| `subscription_id` | Required | Onboarded Azure subscription UUID |
| `location`, `availability_zone` | Required | Region and Azure logical zone matching the Network Anchor |
| `resource_anchor_id`, `network_anchor_id` | Required | Existing anchor ARM IDs |
| `resource_group_name` | `rg-oradb-workload` | Workload group for newly created resources |
| `create_resource_group` | `false` | Set true only to create a new workload group |
| `existing_cloud_exadata_infrastructure_id` | `null` | Existing compatible capacity; supplied ID skips infrastructure creation |
| `infrastructure` | `oradb-infra`, `Exadata.X9M`, 2 compute / 3 storage | New capacity name, shape and server counts; ignored for reuse |
| `vm_cluster_name` | `oradb-vmcluster` | Cluster resource/display name |
| `hostname` | Required | Short hostname prefix; letters/digits/hyphens |
| `gi_version` | Required | Available numeric dotted Grid Infrastructure version |
| `ssh_public_keys` | Required | One or more RSA OpenSSH public keys |
| `db_servers` | `null` | Selected OCI DB server OCIDs; required for existing infrastructure |
| `db_server_count` | `2` | Automatic selection size for newly created infrastructure |
| `cpu_core_count` | Required | Positive integer cluster CPU allocation |
| `memory_size_in_gbs` | `256` | Memory allocation; verify capacity/increments |
| `db_node_storage_size_in_gbs` | `256` | Local DB node storage allocation |
| `data_storage_size_in_tbs` | `2` | DATA disk group size in TB |
| `data_storage_percentage` | `80` | One of 35, 40, 60 or 80 |
| `license_model` | `BringYourOwnLicense` | `BringYourOwnLicense` or `LicenseIncluded` (Azure API enum values) |
| `time_zone` | `UTC` | Oracle-supported time zone |
| `is_local_backup_enabled`, `is_sparse_diskgroup_enabled` | `false` | Local backup and SPARSE disk group options |
| `data_collection_options` | All false | Diagnostic events, health monitoring and incident-log preferences |
| `tags` | `{}` | Tags on newly created resources |

New infrastructure uses the service's unrestricted maintenance scheduling preference (`NoPreference`) with rolling patching (`Rolling`). This template does not expose custom maintenance schedules, proximity placement, Exascale storage, or advanced cluster options.

## Outputs

| Name | Description |
| --- | --- |
| `cloud_exadata_infrastructure_id` | Created or reused infrastructure Azure ARM ID |
| `cloud_exadata_infrastructure_ocid` | Infrastructure OCI OCID |
| `vm_cluster_id` | VM cluster Azure ARM ID |
| `vm_cluster_ocid` | VM cluster OCI OCID for subsequent database provisioning |
| `resource_anchor_id`, `network_anchor_id` | Existing anchor ARM IDs used by this deployment |
| `resource_group_id` | Workload group Azure ARM ID |
| `db_server_ocids` | Selected OCI DB server IDs |

## Usage

1. Deploy the Resource and Network Anchors, keeping their Terraform states separate. Copy their output ARM IDs into this template's variables.
2. Authenticate and configure the deployment:

   ```sh
   az login
   az account set --subscription "<subscription-id>"
   cp terraform.tfvars.template terraform.tfvars
   ```

   Edit the Common, Resource Group, Anchors, Exadata Infrastructure and VM Cluster sections. Replace all placeholders and the zero subscription UUID. Keep `existing_cloud_exadata_infrastructure_id = null` to create both resources. Numeric sample allocations are illustrative; confirm shape-specific limits and increments.
3. Review and deploy:

   ```sh
   terraform init
   terraform fmt -check
   terraform validate
   terraform plan -out=deploy.tfplan
   terraform apply deploy.tfplan
   terraform output
   terraform plan -detailed-exitcode
   ```

A clean post-deployment plan exits `0`, changes exit `2`, and errors exit `1`. Wait for an operation to finish before running another against the same state. Use access-controlled state and plan storage; retain the generated provider lock file. Supply authentication through Azure CLI or provider-supported `ARM_*` environment variables. Do not commit private inputs, credentials or state.

Confirm service support before modifying a deployed cluster's sizing or configuration. Create-only changes, such as anchors, selected DB servers, hostname or GI version, trigger replacement.

### DB server selection

For new infrastructure, Terraform discovers its DB server inventory after provisioning and selects the first `db_server_count` OCI OCIDs in sorted order, defaulting to two. If inventory is not yet ready, allow it to populate before replanning. Immediately after the first apply, persist the `db_server_ocids` output as the `db_servers` input before any infrastructure edit, including tags. Such edits can defer inventory reads and produce a cluster replacement plan while automatic selection remains enabled; adding servers can also change the sorted selection.

For existing infrastructure, supply at least two distinct `db_servers` OCI OCIDs explicitly. Read the inventory and review existing allocations:

```sh
az rest --method get --url "https://management.azure.com<infrastructure-arm-id>/dbServers?api-version=2026-06-01" --query 'value[].{ocid:properties.ocid,state:properties.lifecycleState,clusters:properties.vmClusterIds,cpuUsed:properties.cpuCoreCount,cpuMax:properties.maxCpuCount,memoryUsed:properties.memorySizeInGbs,memoryMax:properties.maxMemoryInGbs}' -o json
```

Follow any returned `nextLink` for paged results. Use `properties.ocid`, not child Azure ARM IDs or display names. The template verifies membership; the service validates readiness and available CPU, memory, local storage and supported VM counts. `Available` does not mean unoccupied. Memory and local DB node storage inputs are cluster totals distributed across selected servers; confirm per-server minimums/increments and memory divisibility.

Existing infrastructure must match the selected Resource Anchor, region and zone. It is referenced without being imported or managed by this state. Never manage the same resource from multiple Terraform states.

### Placement and database provisioning

Matching visible region and logical-zone values alone does not establish underlying infrastructure/network placement compatibility. Resolve service-reported placement conflicts by confirming a compatible infrastructure/Network Anchor pair with Oracle before retrying unchanged inputs.

Create DB homes and databases separately using a supported workflow, such as the [Oracle Exadata Terraform tutorial](https://docs.oracle.com/en/learn/dbazure-terraform/index.html#next-steps), with the resulting VM cluster OCI OCID.

## Cleanup

Remove databases and DB homes before destroying their VM cluster:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Terraform deletes the VM cluster before infrastructure created by this template. Reused infrastructure, anchors and networking are retained. If this template created the workload group, remove other deployments' resources from it before destruction. Delete dependent workloads first, then the Network Anchor deployment, and finally the Resource Anchor deployment.

See the [Exadata infrastructure API](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2026-06-01/cloudexadatainfrastructures), [VM cluster API](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2026-06-01/cloudvmclusters) and [Oracle Exadata VM cluster guidance](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/azucr-create-exadata-vm-cluster.html).

### X11M server types

When creating `Exadata.X11M` or `Exadata.X11MV`, set both `infrastructure.database_server_type` and `infrastructure.storage_server_type`. Obtain the supported names for the target subscription and region from the `Oracle.Database/locations/flexComponents` API, filtering by shape. Server-type availability varies by environment; do not infer the names from the shape. Leave both unset for older shapes. Changing server types replaces infrastructure.

```bash
az rest --method get --url "https://management.azure.com/subscriptions/<subscription-id>/providers/Oracle.Database/locations/<region>/flexComponents?api-version=2026-06-01&shape=Exadata.X11M"
```
