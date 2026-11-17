# Quickstart Oracle Database@Azure Network Anchor with AzAPI

This standalone Terraform template provisions a Network Anchor using the AzAPI v2 provider and the stable `2025-09-01` Oracle.Database API. It provides a network foundation for supported Oracle Database@Azure deployments without requiring an AzureRM Network Anchor resource.

By default, it creates:

- An Azure resource group (optional).
- A VNet and a subnet delegated to `Oracle.Database/networkAttachments` (optional).
- An Oracle Database@Azure Resource Anchor (optional), which maps the Azure resource group to an OCI compartment.
- An Oracle Database@Azure Network Anchor in a selected region and availability zone.

Existing resource groups, Resource Anchors, and delegated subnets can be reused. To manage the Resource Anchor in a separate deployment, use the companion [Resource Anchor quickstart](../azapi-oci-resource-anchor-quickstart) and pass its output as `existing_resource_anchor_id` with `create_resource_group = false`. Oracle resources use AzAPI; the resource group and Azure networking use AzureRM. No OCI credentials or local modules are required. This template does not provision database infrastructure, VM clusters, or databases.

## Prerequisites

1. Terraform `>= 1.9, < 2.0`, Azure CLI, and access to download the `Azure/azapi` 2.x and `hashicorp/azurerm` 4.x providers.
2. Complete [Oracle Database@Azure onboarding](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/onboard-service.htm), including the applicable offer, OCI account linking, consent, and service permissions. Creating a Resource Anchor is not a replacement for onboarding.
3. Use a subscription, region, and **Azure logical availability zone** supported for the intended Oracle database deployment. Availability and capacity depend on your subscription; the sample region/zone are examples. Keep the Network Anchor and VNet in the same region. Resource Anchors are global resources replicated across regions. Reuse a Resource Anchor in the same subscription and resource group as the Network Anchor; check for an existing anchor before creating another.
4. Your identity needs permission to create the selected Oracle and Azure resources and join the delegated subnet. Follow your organization's Oracle Database@Azure RBAC requirements. The `Oracle.Database` and `Microsoft.Network` resource providers must already be registered. Registration requires subscription-level permission; this template does not change provider registrations.
5. Plan private IPv4 addressing. New client subnets accept `/22` through `/27`; `/24` leaves room for growth. Place the client subnet inside the VNet address space. Backup CIDRs must not overlap the VNet or other connected networks; `/24` is recommended and `/22` is the maximum address-space size. The backup CIDR is an OCI-side range, not a second Azure subnet. An Exadata deployment requires backup networking; the example supplies a backup CIDR, while the API property remains optional for other services. Terraform validates CIDR syntax and size; verify private addressing, containment, overlap, and capacity for your topology before applying.

For existing networking, the subnet must already be delegated to **`Oracle.Database/networkAttachments`**, have sufficient free addresses, and be in the same subscription and region. It can be in a different resource group. The template references its ARM ID without taking ownership or changing its configuration; Azure validates its compatibility during deployment.

See Oracle's [Network Anchor instructions](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/azucr-create-network-anchor.html) and [delegated subnet design](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-delegated-subnet-design.htm).

## Authenticate and deploy

Run from this directory (or copy this directory on its own):

```sh
az login
az account set --subscription "<subscription-id>"
# Confirm registration; ask your subscription administrator if not Registered.
az provider show --namespace Oracle.Database --query registrationState -o tsv
az provider show --namespace Microsoft.Network --query registrationState -o tsv

cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your subscription, region, zone and address plan.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=deploy.tfplan
terraform apply deploy.tfplan
terraform output network_anchor_id
```

Both providers use the selected subscription through `subscription_id` and support Azure CLI authentication. For unattended deployments, configure supported service principal or workload identity credentials through the providers' `ARM_*` environment variables; do not put credentials in `.tfvars` files. Consult [AzAPI authentication](https://registry.terraform.io/providers/Azure/azapi/latest/docs) and [AzureRM authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs). Store Terraform state and saved plans securely; use a remote backend with access control for shared/customer deployments. Retain the generated dependency lock file for reproducible provider selection.

## Reuse existing resources

Replace the corresponding settings in `terraform.tfvars` with:

```hcl
subscription_id   = "00000000-0000-0000-0000-000000000000"
location          = "eastus"
availability_zone = "1"

create_resource_group = false
resource_group_name   = "rg-oradb-existing"
network_anchor_name   = "oradb-network-anchor"

create_network = false
existing_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-oradb/subnets/snet-oradb"
existing_resource_anchor_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-existing/providers/Oracle.Database/resourceAnchors/oradb-resource-anchor"

oci_backup_cidr_block = "192.168.252.0/24"
```

Reuse a Resource Anchor only with its existing resource group (`create_resource_group = false`). Other choices can be combined: for example, reuse an existing resource group and subnet while leaving `existing_resource_anchor_id = null` to create its Resource Anchor. `create_network = false` reuses the VNet/subnet together; this quickstart does not add a subnet to an existing VNet. New-network names and CIDRs are ignored when networking is reused. Import resources first if you intend Terraform to manage resources that already exist; simply selecting their names does not import them.

## Optional DNS settings

Unset DNS properties are omitted from the request, allowing service defaults to apply. Confirm DNS feature availability for your target database service and region before enabling these options. For example:

```hcl
dns = {
  listening_endpoint_enabled       = true
  listening_endpoint_allowed_cidrs = ["10.20.2.0/24"]
  forwarding_endpoint_enabled      = true
  forwarding_rules = [{
    domain_names          = ["app.example.com", "corp.example.com"]
    forwarding_ip_address = "10.20.3.4" # Existing Azure/customer DNS inbound endpoint.
  }]
}
```

Each forwarding rule sends its domain list as a comma-separated `domainNames` string. The allowed CIDRs similarly become a comma-separated `dnsListeningEndpointAllowedCidrs` string. `oci_vcn_dns_label` defaults to `oradb` and is sent as a create-time request. The service can return a canonical label derived from the VNet name instead; use the provisioned DNS names when configuring clients. The template accepts service changes to this one response field to avoid repeated drift, while an explicit change to the input still triggers anchor replacement. Set the input to null only when supplying a DNS configuration supported by your database service.

DNS listening accepts requests from the configured source ranges; it does not automatically configure your Azure or on-premises resolvers. Configure conditional forwarding for the database domain to the listening endpoint and allow DNS traffic along the route. Forwarding rules need a reachable DNS server/inbound endpoint. This template does not create Azure DNS Private Resolver endpoints, private DNS zones, VNet links, or security/routing rules. Choose either DNS listening or `zone_sync_enabled = true` for OCI-to-Azure private-zone replication according to your resolution design; Oracle documents these as overlapping functions. Refer to [Oracle DNS guidance](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-dns.htm).

## Inputs and outputs

| Input | Default | Purpose |
| --- | --- | --- |
| `subscription_id` | Required | Onboarded Azure subscription UUID |
| `location` | Required | Azure region |
| `availability_zone` | Required | Azure logical availability zone |
| `create_resource_group` | `true` | Create or reuse the named group |
| `resource_group_name` | `rg-oradb-network` | Group for both anchors and newly created networking |
| `network_anchor_name` | `oradb-network-anchor` | Network Anchor name |
| `resource_anchor_name` | `oradb-resource-anchor` | Name used when creating a Resource Anchor |
| `existing_resource_anchor_id` | `null` | Reuse an anchor instead of creating one |
| `create_network` | `true` | Create VNet/subnet or reuse `existing_subnet_id` |
| `existing_subnet_id` | `null` | Required when `create_network = false` |
| `virtual_network_name` | `vnet-oradb` | New VNet name |
| `virtual_network_address_space` | `["10.20.0.0/16"]` | New VNet IPv4 ranges |
| `delegated_subnet_name` | `snet-oradb` | New subnet name |
| `delegated_subnet_address_prefix` | `10.20.1.0/24` | New client subnet range |
| `oci_backup_cidr_block` | `null` | Optional OCI backup range; set for Exadata as appropriate |
| `oci_vcn_dns_label` | `oradb` | OCI VCN DNS label |
| `dns` | `{}` | Optional endpoint, forwarding and zone-sync settings |
| `tags` | `{}` | Tags for newly created resources |

Outputs are `network_anchor_id`, `resource_anchor_id`, `subnet_id`, and `resource_group_id`. Each is an Azure ARM resource ID, not an OCI OCID.

## Use the Network Anchor in a database deployment

```sh
terraform output -raw network_anchor_id
```

Pass this value to a downstream Oracle.Database resource/API that supports the `networkAnchorId` property. For example, in that resource's AzAPI body:

```hcl
# Fragment to merge into the properties of a separately configured resource.
properties = {
  networkAnchorId = var.network_anchor_id
  # Other properties required by the selected database resource/API version...
}
```

Keep the database deployment aligned with the anchor's region, zone and network. See the [Oracle Exadata Terraform tutorial](https://docs.oracle.com/en/learn/dbazure-terraform/index.html#next-steps) for the broader database provisioning workflow. The existing `avm-oci-exadata-quickstart` template uses its own networking and older AVM resource interfaces; it does not accept this output directly. Integrating anchors requires a downstream module/API version that exposes the anchor property and adjustment of that deployment's inputs.

For a complete live test with separate Resource Anchor and Network Anchor states, environment inspection, drift checks and ordered cleanup, follow the [step-by-step live test guide](../azapi-oci-resource-anchor-quickstart#step-by-step-live-test-of-both-templates).

## Cleanup and local checks

Delete dependent database resources before destroying the Network Anchor. Review the destroy plan, especially if the Resource Anchor or networking is shared:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Terraform destroys resources this template created; reused subnet, Resource Anchor and resource group references are left in place. Keep anchors until all dependent workloads are removed. Changes to the anchor's zone, network, resource anchor, VCN DNS label, DNS forwarding rules or listening CIDR allowlist trigger replacement because these settings are configured at creation. Backup CIDR and DNS enablement flags can update in place, subject to service constraints. Remove attached database resources before applying such a replacement; review the plan before proceeding.

The mock-provider tests exercise plans and validation without Azure credentials or cloud changes:

```sh
terraform init -backend=false
terraform fmt -check
terraform validate
terraform test
```

Mock plans do not verify service availability, permissions, quota, capacity, existing-resource compatibility, or a live deployment.

API references: [Network Anchors 2025-09-01](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2025-09-01/networkanchors), [Resource Anchors 2025-09-01](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2025-09-01/resourceanchors).
