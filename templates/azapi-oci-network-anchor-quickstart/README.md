# Quickstart Oracle Database@Azure Network Anchor with AzAPI

## Summary

Terraform template for provisioning an Oracle Database@Azure Network Anchor with AzAPI. It creates or reuses an Azure resource group, a Resource Anchor, and a VNet with an Oracle delegated subnet. Oracle resources use the stable `2025-09-01` API. No OCI credentials are required.

For separate deployments, create the [Resource Anchor](../azapi-oci-resource-anchor-quickstart) first, reuse its ID here, and pass both anchor IDs to the [Exadata infrastructure and VM cluster template](../azapi-oci-exadata-quickstart).

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.9, < 2.0 |
| Azure CLI | Supported version for authentication |

- Complete [Oracle Database@Azure onboarding](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/onboard-service.htm), offer acceptance, account linking and consent. Register `Oracle.Database` and `Microsoft.Network`; providers do not register them automatically.
- Your identity needs permission to manage the selected Oracle and Azure resources and join the subnet. Follow your organization's Oracle Database@Azure RBAC requirements.
- Select a supported region and Azure logical availability zone. Keep the VNet and Network Anchor in the same region. Resource Anchors are global; check for an existing anchor before creating another. Reused Resource Anchors must be in the same subscription and resource group as this template's Network Anchor.
- Use private IPv4 ranges without overlaps across connected networks. The client subnet must be within its VNet and sized `/22` through `/27`; `/24` allows room for growth. For Exadata, plan the separate OCI backup CIDR before deployment: `/24` is recommended and `/22` is the maximum address-space size. The backup range must not overlap the VNet or connected networks; it is not a second Azure subnet. Terraform checks syntax and size; verify private addressing, containment, overlap and capacity for your topology.
- A reused subnet must already be delegated to `Oracle.Database/networkAttachments`, have sufficient addresses and be in the same subscription and region. It can be in a different resource group. This template references it without changing its configuration.

## Providers

| Name | Version | Purpose |
| --- | --- | --- |
| Azure/azapi | ~> 2.0 | Network Anchor and optional Resource Anchor |
| hashicorp/azurerm | ~> 4.0 | Resource group and Azure networking |

## Resources

| Name | Type | Behavior |
| --- | --- | --- |
| `azapi_resource.network_anchor` | Oracle.Database/networkAnchors@2025-09-01 | Create Network Anchor |
| `azapi_resource.resource_anchor` | Oracle.Database/resourceAnchors@2025-09-01 | Optional Resource Anchor at location `global` |
| `azurerm_resource_group.this` | Resource group | Optional new resource group |
| `azurerm_virtual_network.this` | Virtual network | Optional new VNet |
| `azurerm_subnet.oracle` | Subnet | Optional subnet with Oracle delegation |
| `data.azurerm_resource_group.this` | Resource group data source | Read an existing group |

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `subscription_id` | Required | Onboarded Azure subscription UUID |
| `location`, `availability_zone` | Required | Azure region and logical zone |
| `create_resource_group` | `true` | Create or reuse the named group |
| `resource_group_name` | `rg-oradb-network` | Group for anchors and new networking |
| `network_anchor_name` | `oradb-network-anchor` | Network Anchor name, 3–24 letters/numbers/hyphens |
| `resource_anchor_name` | `oradb-resource-anchor` | Name used when creating a Resource Anchor |
| `existing_resource_anchor_id` | `null` | Reuse an anchor instead of creating one |
| `create_network` | `true` | Create a VNet/subnet or reuse `existing_subnet_id` |
| `existing_subnet_id` | `null` | Required when `create_network = false` |
| `virtual_network_name` | `vnet-oradb` | New VNet name |
| `virtual_network_address_space` | `["10.20.0.0/16"]` | New VNet IPv4 ranges |
| `delegated_subnet_name` | `snet-oradb` | New subnet name |
| `delegated_subnet_address_prefix` | `10.20.1.0/24` | New client subnet range |
| `oci_backup_cidr_block` | `null` | OCI backup range; configure for Exadata as required |
| `oci_vcn_dns_label` | `oradb` | Requested create-time OCI VCN DNS label |
| `dns` | `{}` | Optional DNS endpoints, forwarding and zone sync |
| `tags` | `{}` | Tags for resources created by this template |

## Outputs

| Name | Description |
| --- | --- |
| `network_anchor_id` | Network Anchor Azure ARM ID |
| `resource_anchor_id` | Created or reused Resource Anchor Azure ARM ID |
| `subnet_id` | Created or reused delegated subnet Azure ARM ID |
| `resource_group_id` | Created or reused resource group Azure ARM ID |

## Usage

```sh
az login
az account set --subscription "<subscription-id>"
cp terraform.tfvars.template terraform.tfvars
# Edit subscription, region, zone, names and address ranges.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=deploy.tfplan
terraform apply deploy.tfplan
terraform output
```

Use Azure CLI or provider-supported `ARM_*` environment variables for authentication. Store state and saved plans securely and retain the generated provider lock file. Do not commit private inputs, credentials or state.

To reuse existing resources, set `create_resource_group = false`, `resource_group_name` and `existing_resource_anchor_id` to the existing anchor's group and ARM ID. Set `create_network = false` and `existing_subnet_id` to use an existing VNet/subnet together. New-network names and CIDRs are then ignored; this template does not add subnets to existing VNets. Reusing a reference does not import or manage that resource.

### Optional DNS

Unset DNS properties are omitted so that service defaults apply. Confirm DNS feature availability for your database service and region. For example:

```hcl
dns = {
  listening_endpoint_enabled       = true
  listening_endpoint_allowed_cidrs = ["10.20.2.0/24"]
  forwarding_endpoint_enabled      = true
  forwarding_rules = [{
    domain_names          = ["app.example.com", "corp.example.com"]
    forwarding_ip_address = "10.20.3.4"
  }]
}
```

Listening CIDRs and each rule's domain list become comma-separated API strings. Listening requires customer-managed conditional forwarding for the database domain; forwarding requires a reachable DNS server/inbound endpoint. Configure resolver endpoints, DNS zones/links, security rules and routes separately. Choose listening or `zone_sync_enabled = true` according to your DNS design; Oracle documents them as overlapping functions.

The service can return a VNet-derived DNS label instead of the requested `oci_vcn_dns_label`. The template accepts this canonical response field to avoid repeated drift. Changing the label input still triggers replacement. Set the input to null only with a DNS configuration supported by your database service.

Use the output anchor IDs with the [Exadata template](../azapi-oci-exadata-quickstart). Its stable `2026-06-01` API supports anchor properties. The older `avm-oci-exadata-quickstart` template has separate networking and does not accept these outputs directly.

## Cleanup

Remove dependent databases and infrastructure before destroying their Network Anchor:

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Reused resources remain in place. Changes to zone, subnet, Resource Anchor, VCN DNS label, forwarding rules or listening CIDRs trigger anchor replacement; remove dependent workloads first. Backup CIDR and DNS enablement flags use service-supported update behavior.

See [Oracle Network Anchors](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/azucr-create-network-anchor.html), [subnet design](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-delegated-subnet-design.htm), [DNS guidance](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/network-dns.htm) and the [API reference](https://learn.microsoft.com/en-us/azure/templates/oracle.database/2025-09-01/networkanchors).
