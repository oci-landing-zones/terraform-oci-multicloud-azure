# Quickstart Exadata infrastructure and VM cluster with existing anchors

This standalone Terraform template creates Oracle Database@Azure dedicated Exadata infrastructure and a Cloud VM Cluster using existing Resource and Network Anchors. It uses AzAPI v2 with the stable `2026-06-01` API, which exposes Exadata anchor properties. The anchor quickstarts use `2025-09-01`; that older API does not expose the anchor fields needed on these Exadata resources.

Leave `existing_cloud_exadata_infrastructure_id = null` (the default) to create **both new Exadata infrastructure and its VM cluster**. Supply the existing `resource_anchor_id` and `network_anchor_id` from the companion quickstarts; these anchors remain owned by their original deployments. Set an existing infrastructure ID only when you intentionally want to create a VM cluster on existing capacity.

The infrastructure receives `resourceAnchorId`. The VM cluster receives `resourceAnchorId`, `networkAnchorId` and the infrastructure ID. The infrastructure selects an Azure logical zone through `zones`; the VM cluster uses the selected infrastructure and Network Anchor placement and has no top-level `zones` field. Its optional `zoneId` denotes an OCI DNS zone, so it is not set to an Azure zone number. The VM cluster API also requires `vnetId` and `subnetId`; the template reads both from the selected Network Anchor. It creates no anchors, VNet, subnet, DB home, database, or passwords. Optionally reuse existing infrastructure and create only its VM cluster.

**Applying this template allocates paid dedicated Exadata capacity and database compute.** Confirm availability, quota, sizing, licensing and costs with your organization and Oracle before applying. Infrastructure and cluster provisioning can take hours; operation timeouts are 24 hours. Offline validation does not establish capacity or feature availability. No live Exadata or VM cluster deployment is part of this template's local validation.

## Prerequisites and deployment chain

Deploy in this order, keeping each template's Terraform state separate:

1. [Resource Anchor quickstart](../azapi-oci-resource-anchor-quickstart): save `resource_anchor_id`.
2. [Network Anchor quickstart](../azapi-oci-network-anchor-quickstart): reuse that Resource Anchor and save `network_anchor_id`. Configure sufficient client and backup addressing for Exadata before creating this anchor.
3. This template: create infrastructure, then its VM cluster. Terraform orders these resources automatically. If reusing infrastructure, ensure it is ready and has sufficient unallocated capacity, and explicitly select its DB server OCI OCIDs as described below.
4. Provision DB homes/databases separately using a supported workflow, such as the [Oracle Exadata Terraform tutorial](https://docs.oracle.com/en/learn/dbazure-terraform/index.html#next-steps). This template outputs the VM cluster OCI OCID for such workflows.

Requirements:

- Terraform `>= 1.9, < 2.0`, Azure CLI, published `Azure/azapi` 2.x and `hashicorp/azurerm` 4.x providers.
- Complete Oracle Database@Azure onboarding, offer acceptance, account linking, consent and service permissions. Verify Exadata anchor-based provisioning is available for your subscription and region before applying; an advertised API version alone does not establish this.
- Register `Oracle.Database` before deployment. Both providers disable automatic registration. Your identity needs read access to the referenced anchors and any existing infrastructure; create/read/update/delete permissions for the new Oracle resources; read access to the workload resource group; and resource-group creation permission if selected. Follow your organization's Oracle Database@Azure RBAC requirements.
- This quickstart supports a single subscription for all resources; cross-subscription anchor references supported by the service are outside its scope. The Network Anchor must reference your selected Resource Anchor and match the deployment region and Azure logical availability zone. Existing infrastructure must match the Resource Anchor, region and zone. The template checks these associations. Resource Anchors use global location; this template does not require matching their location to the regional workload.
- Resource-group ownership is explicit: the selected `resource_group_name` owns the new infrastructure and VM cluster, while the anchor IDs retain their original resource groups. The template does not require matching group names. Confirm cross-group access and the service's compartment/placement permissions for your environment. Keep the chosen Resource Anchor consistent across infrastructure and cluster.
- Select an available shape, Grid Infrastructure version, compute/storage allocation and licensing model. The example numeric allocations are illustrative; limits, increments and availability vary by shape and server layout. Use a supported Oracle time zone. Plan short hostname prefixes and ensure generated DNS names resolve from database clients.
- Supply an existing **RSA public SSH key** (2048 bits or greater, single-line OpenSSH `ssh-rsa` format). Never supply private key material. The template checks the public-key format; the service validates the actual key and supported length.

## Edit inputs and deploy

Run from this directory, or copy the directory on its own:

```sh
az login
az account set --subscription "<subscription-id>"
az account show --query '{subscription:id,name:name,tenant:tenantId}' -o table
az provider show --namespace Oracle.Database --query registrationState -o tsv

cp terraform.tfvars.example terraform.tfvars
# Replace ALL <...> placeholders and the zero subscription UUID in the local file.
# Paste actual ARM IDs from the anchor quickstarts' Terraform outputs.
terraform init
terraform fmt -check
terraform validate
terraform test  # Offline mocks only; no deployment or Azure credentials needed.
terraform plan -out=deploy.tfplan
# Review planned capacity, licensing, anchors, sizing and costs before applying.
terraform apply deploy.tfplan
terraform output
terraform plan -detailed-exitcode
```

A clean post-apply plan exits `0`; changes exit `2`; errors exit `1`. Wait for each apply to finish before starting another Terraform operation against its state. Keep shared state and saved plans in an access-controlled backend/storage. Inputs (`terraform.tfvars`), JSON variable files, state and `*.tfplan` files are ignored by this repository; do not commit environment identifiers, credentials, or private keys. Retain the generated dependency lock file for reproducible provider selection.

Both providers support Azure CLI authentication. For automation, configure supported workload identity/service principal credentials through provider `ARM_*` environment variables; consult [AzAPI](https://registry.terraform.io/providers/Azure/azapi/latest/docs) and [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) authentication documentation.

You can inspect resources without changing them:

```sh
az resource show --ids "<resource-anchor-id>" --api-version 2025-09-01
az resource show --ids "<network-anchor-id>" --api-version 2025-09-01
az resource show --ids "<infrastructure-id>" --api-version 2026-06-01
az resource show --ids "<vm-cluster-id>" --api-version 2026-06-01
```

Check provisioning state, anchors, region/zone, capacity, and OCI OCIDs after deployment. The template verifies network/infrastructure associations before VM cluster creation; Azure/Oracle still validates permissions, capacity, backup network readiness and feature availability. Do not change deployed cluster sizing/configuration without confirming that the service supports the corresponding update in anchor mode. Create-only input changes (such as anchor, hostname, GI version or placement) trigger replacement; remove dependent databases before applying replacements.

## Placement errors

The template checks that the Network Anchor and infrastructure share the selected region and Azure logical availability zone. Matching those values alone does not guarantee that the service's underlying network and infrastructure placement are compatible. If creation reports that the subnet is linked to a resource in a different availability zone despite matching visible inputs, verify the selected infrastructure, Network Anchor and delegated subnet associations, then resolve placement with Oracle support or select a confirmed compatible infrastructure/anchor pair. Repeatedly retrying the same unchanged request will not resolve a placement conflict. Do not modify shared networking or existing workloads to work around it without assessing their dependencies.

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

## Select DB servers

VM cluster creation requires `dbServers`: the **OCI OCIDs** of the compute servers on which its VMs run. Azure child resource IDs and server display names are not accepted.

For newly created infrastructure, leave `db_servers = null`. After infrastructure provisioning completes, Terraform lists its `/dbServers` inventory and selects the first `db_server_count` OCIDs in sorted order (default **two**, even when the infrastructure has more compute servers). The list read is deferred until the new infrastructure exists, so a combined deployment can discover its server IDs without an extra manual step. If the service has not yet populated the inventory, let it become ready and rerun the plan. This does not prove capacity or readiness; Azure/Oracle validates allocation at creation.

For **existing infrastructure**, `db_servers` is required: choose at least two distinct server OCIDs from that infrastructure after reviewing their current allocations. Inspect the inventory read-only:

```sh
az rest --method get --url "https://management.azure.com<infrastructure-arm-id>/dbServers?api-version=2026-06-01" --query 'value[].{ocid:properties.ocid,state:properties.lifecycleState,clusters:properties.vmClusterIds,cpuUsed:properties.cpuCoreCount,cpuMax:properties.maxCpuCount,memoryUsed:properties.memorySizeInGbs,memoryMax:properties.maxMemoryInGbs}' -o json
```

Follow any returned `nextLink` when inspecting paged results. Then set local inputs, using actual OCIDs from `properties.ocid`:

```hcl
db_servers = [
  "ocid1.dbserver.<realm>.<region>.<server-1-id>",
  "ocid1.dbserver.<realm>.<region>.<server-2-id>",
]
```

The template checks membership in the selected infrastructure; it does not automatically reserve capacity or assume that `Available` means unoccupied. Servers can legitimately host multiple clusters, so assess remaining CPU, memory, local storage and supported VM counts before selection. `memory_size_in_gbs` and `db_node_storage_size_in_gbs` are cluster totals distributed across the selected servers; check per-server minimums and increments, and ensure the memory total divides evenly by the server count.

After an automatic deployment, `terraform output db_server_ocids` shows the chosen IDs. Pin those same values in `db_servers` before adding hardware or changing server inventory: lexicographic ordering can change when servers are added. An explicit selection change triggers cluster replacement. Inventory is not filtered by cluster associations during refresh, which keeps this template's own allocated servers selected after creation.

## Reuse infrastructure

Set `existing_cloud_exadata_infrastructure_id` to its Azure ARM ID. The infrastructure must be in the selected subscription, match the Resource Anchor, region and zone, and have available capacity. Supply an explicit `db_servers` list from its server inventory. The template reads it and creates only the new VM cluster; it does not manage/delete that infrastructure or import it into this state. Do not manage one resource from multiple Terraform states. Existing infrastructure without the selected Resource Anchor association is rejected by this anchored workflow.

## Outputs and cleanup

Outputs: `cloud_exadata_infrastructure_id` and `vm_cluster_id` are Azure ARM IDs; `cloud_exadata_infrastructure_ocid` and `vm_cluster_ocid` are OCI OCIDs. `resource_anchor_id` and `network_anchor_id` identify the existing anchors used by the deployment for traceability. `resource_group_id` identifies the workload group. `db_server_ocids` contains the selected OCI DB server IDs.

Remove databases and DB homes created by other workflows before deleting their cluster. Then review and apply this template's destroy plan:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Terraform deletes the VM cluster before infrastructure it created. Reused infrastructure, anchors and networking are left in place. A workload group created by this template is also deleted; remove separately managed resources from it first. Only after these workloads are gone should you destroy the Network Anchor deployment and then the Resource Anchor deployment. See the [anchor live test guide](../azapi-oci-resource-anchor-quickstart#step-by-step-live-test-of-both-templates) for the earlier chain's ordered cleanup.

## Offline checks and API references

```sh
terraform init -backend=false
terraform fmt -recursive -check
terraform validate
terraform test
```

Mocks cover new capacity with deterministic server discovery, explicit server selection on reused capacity, anchor-derived networking, association checks and invalid inputs. They do not demonstrate a live paid-resource deployment or successful service updates.

- [Exadata infrastructure stable API](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2026-06-01/cloudexadatainfrastructures)
- [Cloud VM cluster stable API](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2026-06-01/cloudvmclusters)
- [Public Oracle.Database REST specification](https://github.com/Azure/azure-rest-api-specs/blob/main/specification/oracle/resource-manager/Oracle.Database/OracleDatabase/stable/2026-06-01/openapi.json)
