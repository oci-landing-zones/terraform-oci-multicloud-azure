# Quickstart complete Oracle Database@Azure Exadata chain with AzAPI

## Summary

This Terraform root composes the four reusable AzAPI modules into one deployment:

**Resource Anchor → Network Anchor → Exadata infrastructure → VM cluster**

The default creates a resource group, VNet, delegated subnet and the four Oracle resources: **seven managed resources in one Terraform state**. Resource and Network Anchor IDs are passed between modules automatically. Exadata provisioning starts after the Network Anchor is ready; DB server inventory is discovered after infrastructure provisioning, then the VM cluster is created. One saved plan/apply can deploy the chain without manually copying anchor IDs between stages.

All resources share one resource group and one Resource Anchor. You can instead look up previously created anchors in that group by name and resource group. Reused anchors are read, not imported or managed. This root always creates new Exadata infrastructure and a VM cluster. To reuse existing Exadata capacity, use the separate [existing-anchor Exadata quickstart](../azapi-oci-exadata-quickstart).

**Applying allocates paid dedicated Exadata capacity and database compute.** Confirm capacity, licensing, sizing and service availability before applying. Provisioning can take hours; Exadata module operations have 24-hour timeouts. DB homes and databases are provisioned separately.

## Requirements

- Terraform `>= 1.9, < 2.0`, Azure CLI for interactive authentication, `Azure/azapi ~> 2.0`, and `hashicorp/azurerm ~> 4.0`.
- Complete Oracle Database@Azure onboarding, offer acceptance, consent and OCI account linking. Register `Oracle.Database` and, when managing networking, `Microsoft.Network`. Providers do not register them automatically.
- Use one onboarded subscription with Exadata anchor-based provisioning and capacity available in the selected region/zone. Grant the execution identity permission to manage new Oracle/Azure resources and read reused anchors, their associated Resource Anchor and DB server inventory. Follow your organization's RBAC requirements.
- Match the Network Anchor and infrastructure region and Azure logical availability zone. A Resource Anchor uses location `global`. Matching visible region/zone does not establish underlying placement compatibility; confirm a compatible network/infrastructure placement with Oracle before retrying service-reported conflicts.
- Plan non-overlapping private IPv4 ranges. New client subnets accept `/22` through `/27` and must fit within their VNet. The separate OCI backup range defaults to `/24`; ensure adequate capacity and no overlap with Azure/connected networks. An existing subnet must already be delegated to `Oracle.Database/networkAttachments`, with sufficient free addresses in the selected subscription/region.
- Select an available shape and GI version, sufficient CPU/memory/local/data storage and an appropriate Oracle license model. Provide an RSA public SSH key of at least 2048 bits in single-line OpenSSH format. Never put private keys or credentials in variable files.

Run from a checkout of this repository. The root uses `../../modules/` source paths; copying this directory alone is insufficient. Preserve that layout or adjust module sources to your project, optionally using a pinned Git module source after the chosen revision includes these modules.

## Modules and resources

| Module | API | Purpose |
| --- | --- | --- |
| [resource_anchor](../../modules/azapi-ora-resource-anchor) | 2025-09-01 | Optional new global Resource Anchor |
| [network_anchor](../../modules/azapi-ora-network-anchor) | 2025-09-01 | Optional new zonal Network Anchor |
| [infrastructure](../../modules/azapi-ora-exadata-infra) | 2026-06-01 | New dedicated Exadata infrastructure |
| [vm_cluster](../../modules/azapi-ora-exadata-vmc) | 2026-06-01 | New VM cluster and server inventory reads |

The root owns optional Azure resource-group/VNet/subnet resources. Existing-anchor reads use static subscription/name/group selectors, independent of managed workload-group updates. Their postconditions verify readiness and placement/association before paid infrastructure is allocated. The VM module receives actual infrastructure output IDs to preserve provisioning dependencies; do not replace these references with manually reconstructed IDs.

## Usage

1. Copy and edit the input template, replacing every placeholder and the zero UUID:

   ```sh
   cp terraform.tfvars.template terraform.tfvars
   ```

2. Configure authentication externally. For interactive use:

   ```sh
   az login
   az account set --subscription "<subscription-id>"
   ```

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

A clean subsequent plan exits `0`; differences exit `2`; errors exit `1`. Wait for each operation to finish before starting another on the same state. Keep the generated dependency lock file with your deployment for consistent provider selection. Do not run separate Terraform roots against the same managed resources.

### Reuse only a Resource Anchor

This creates a new Network Anchor and new infrastructure/VM cluster. Keep the Network Anchor in the existing Resource Anchor's group, preserving the Network Anchor module's supported scope:

```hcl
create_resource_group = false
resource_group_name   = "<existing-anchor-group>"
existing_resource_anchor = {
  name                = "<resource-anchor-name>"
  resource_group_name = "<existing-anchor-group>"
}
existing_network_anchor = null
```

By default new networking is created in that group. Supply `existing_subnet_id` instead to reuse a compatible delegated subnet in the same group; no new VNet or subnet is then created.

### Reuse an existing Network Anchor

The root retrieves its Resource Anchor and networking automatically. All resources must share the existing anchor group and a single Resource Anchor. No anchor, resource group, VNet or subnet resources are created. This mode creates two managed resources: infrastructure and VM cluster:

```hcl
create_resource_group = false
resource_group_name   = "<existing-anchor-group>"
existing_network_anchor = {
  name                = "<network-anchor-name>"
  resource_group_name = "<existing-anchor-group>"
}
existing_resource_anchor = null
existing_subnet_id       = null
```

Choose resource ownership and reuse mode before the first deployment. Changing existing-anchor selectors or `create_resource_group` afterward does not adopt or transfer previously managed resources: count changes can schedule deletion of anchors, networking or a group this state already owns. Treat mode changes as an explicit ownership/state transition and review the full plan before acting.

The deployment resource group must also contain the Resource Anchor, Network Anchor, VNet and subnet. If you also supply `existing_resource_anchor`, the root verifies that it matches the Resource Anchor referenced by the selected Network Anchor. Lookup objects must identify anchors in the selected resource group and subscription. New-anchor names, DNS settings and networking inputs are ignored for reused anchors; this does not change their configuration.

### DB server selection and repeatable updates

New infrastructure inventory is read after provisioning. With `db_servers = null`, the VM module selects the first `db_server_count` sorted OCI DB server IDs, defaulting to two. If inventory has not populated, allow it to become ready before replanning. The service validates actual available capacity; lifecycle state alone does not show remaining allocations.

Immediately after the first apply, record `db_server_ocids` and persist the same values as the `db_servers` input for subsequent jobs, before **any infrastructure edits, including tags**. Infrastructure changes can defer inventory reads; leaving automatic selection enabled during those edits can make create-only values unknown and cause a replacement plan. Selected server/network/anchor/hostname/GI changes can replace a cluster; review every plan. The new-Network-Anchor path supplies known subnet/VNet outputs to the VM module and verifies them against the anchor, keeping immutable network values stable when mutable anchor properties change.

## Pipeline execution

This root is pipeline-platform neutral. Configure a persistent remote backend with locking in the root before running it; the shipped configuration leaves backend selection to the caller and otherwise uses local state. Provision backend storage/access separately. Use one backend key/state for the entire chain and preserve it between runs.

For example, an organization using the Azure Storage backend can add a root `backend.tf` containing:

```hcl
terraform {
  backend "azurerm" {}
}
```

Supply that backend's storage account, container, key and authentication settings through your approved backend configuration during initialization. Select one protected state key for this deployment; configure the backend's access and locking before the first run. See the [Azure Storage backend documentation](https://developer.hashicorp.com/terraform/language/backend/azurerm) for its separate identity and configuration requirements.

Configure the root providers through your pipeline's Azure workload identity/federation and provider-supported `ARM_*` environment settings. OIDC avoids storing a client secret; configure its client/tenant/subscription and token source according to the [AzAPI authentication documentation](https://registry.terraform.io/providers/Azure/azapi/latest/docs) and [AzureRM OIDC documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc). Supply Terraform inputs through an approved variable file or `TF_VAR_*` settings. No pipeline-specific identity or subscription is embedded in this template.

Once identity, backend and inputs are configured, run:

```sh
terraform init -input=false -backend-config="<approved-backend-config-file>"
terraform validate
terraform plan -input=false -out=deploy.tfplan
# Review/approve the saved plan according to your deployment policy.
terraform apply -input=false deploy.tfplan
```

After the initial successful apply, persist the selected server IDs as a protected pipeline artifact/input, for example:

```sh
selected_db_servers="$(terraform output -json db_server_ocids)" || exit 1
printf '{"db_servers":%s}\n' "$selected_db_servers" > db-server-selection.tfvars.json
```

On subsequent jobs, restore this file and include `-var-file=db-server-selection.tfvars.json` on `terraform plan` so it overrides the initial `db_servers = null`. Persisting the same selected IDs does not itself request a server change. Keep the artifact with this deployment, not as a shared global input. Review and resolve any replacement plan before applying infrastructure metadata or capacity changes.

Keep saved plans, inputs, state and public-key material in approved storage, with credentials supplied externally. Do not publish local environment configuration or private keys. Serialize operations on the same state; a long-running Exadata operation must finish before the next run.

## Inputs

| Group | Inputs and defaults |
| --- | --- |
| Common | Required `subscription_id`, `location`, `availability_zone`; `tags = {}` |
| Workload group | `create_resource_group = true`, `resource_group_name = "rg-oradb-anchored"` |
| Existing-anchor lookup | `existing_resource_anchor = null`, `existing_network_anchor = null`; each lookup object contains `name` and `resource_group_name` |
| New anchors | `resource_anchor_name = "oradb-resource-anchor"`, `network_anchor_name = "oradb-network-anchor"`, `oci_vcn_dns_label = "oradb"`, `oci_backup_cidr_block = "192.168.252.0/24"`, `dns = {}` |
| New networking | `existing_subnet_id = null`, `virtual_network_name = "vnet-oradb"`, `virtual_network_address_space = ["10.20.0.0/16"]`, `delegated_subnet_name = "snet-oradb"`, `delegated_subnet_address_prefix = "10.20.1.0/24"` |
| Exadata infrastructure | `infrastructure = { name = "oradb-infra", shape = "Exadata.X9M", compute_count = 2, storage_count = 3 }` |
| VM identity | `vm_cluster_name = "oradb-vmcluster"`; required `hostname`, `gi_version`, `ssh_public_keys` |
| Allocation | Required `cpu_core_count`; `memory_size_in_gbs = 256`, `db_node_storage_size_in_gbs = 256`, `data_storage_size_in_tbs = 2`, `data_storage_percentage = 80` |
| Cluster options | `license_model = "BringYourOwnLicense"`, `time_zone = "UTC"`, `is_local_backup_enabled = false`, `is_sparse_diskgroup_enabled = false`, diagnostic collection flags false |
| Server selection | `db_servers = null`, `db_server_count = 2` |

See [variables.tf](variables.tf) for complete input types and validation. Memory and local DB node storage are cluster totals distributed across selected servers; confirm per-server minimums/increments and memory divisibility. Optional DNS endpoints require separately configured customer DNS forwarding, security and routes; see the [Network Anchor guidance](../azapi-oci-network-anchor-quickstart#optional-dns).

## Outputs

`resource_group_id`, `resource_anchor_id`, `network_anchor_id`, `virtual_network_id`, `subnet_id`, `cloud_exadata_infrastructure_id`, and `vm_cluster_id` are Azure ARM IDs. `cloud_exadata_infrastructure_ocid`, `vm_cluster_ocid`, and `db_server_ocids` are OCI identifiers. Anchor/network outputs identify either created or discovered resources according to the selected mode.

## Cleanup

Remove databases/DB homes created by other workflows, then review and apply:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

For the default new chain, Terraform deletes the VM cluster, infrastructure, Network Anchor and Resource Anchor in dependency order, then their networking/group when no longer referenced. Reused anchors, networks and groups remain outside this state's ownership and are not deleted. Before destroying a group created by this root, remove resources owned by other deployments from it.

### X11M server types

When creating `Exadata.X11M` or `Exadata.X11MV`, set both `infrastructure.database_server_type` and `infrastructure.storage_server_type`. Obtain the supported names for the target subscription and region from the `Oracle.Database/locations/flexComponents` API, filtering by shape. Server-type availability varies by environment; do not infer the names from the shape. Leave both unset for older shapes. Changing server types replaces infrastructure.

```bash
az rest --method get --url "https://management.azure.com/subscriptions/<subscription-id>/providers/Oracle.Database/locations/<region>/flexComponents?api-version=2026-06-01&shape=Exadata.X11M"
```
