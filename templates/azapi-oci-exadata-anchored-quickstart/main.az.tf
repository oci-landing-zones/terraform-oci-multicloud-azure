locals {
  resource_group_id   = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  create_network      = var.existing_network_anchor == null && var.existing_subnet_id == null

  # Lookup IDs depend only on supplied selectors, never on a newly managed group.
  selected_resource_anchor_id = var.existing_resource_anchor == null ? null : "/subscriptions/${var.subscription_id}/resourceGroups/${var.existing_resource_anchor.resource_group_name}/providers/Oracle.Database/resourceAnchors/${var.existing_resource_anchor.name}"
  selected_network_anchor_id  = var.existing_network_anchor == null ? null : "/subscriptions/${var.subscription_id}/resourceGroups/${var.existing_network_anchor.resource_group_name}/providers/Oracle.Database/networkAnchors/${var.existing_network_anchor.name}"
  resource_anchor_id = var.existing_network_anchor != null ? data.azapi_resource.resource_anchor[0].id : (
    var.existing_resource_anchor != null ? data.azapi_resource.resource_anchor[0].id : module.resource_anchor[0].id
  )
  network_anchor_id = var.existing_network_anchor != null ? data.azapi_resource.network_anchor[0].id : module.network_anchor[0].id
  subnet_id = var.existing_network_anchor != null ? data.azapi_resource.network_anchor[0].output.properties.subnetId : (
    local.create_network ? azurerm_subnet.oracle[0].id : var.existing_subnet_id
  )
  vnet_id = var.existing_network_anchor != null ? data.azapi_resource.network_anchor[0].output.properties.vnetId : (
    local.create_network ? azurerm_virtual_network.this[0].id : join("/", slice(split("/", var.existing_subnet_id), 0, 9))
  )
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

data "azapi_resource" "network_anchor" {
  count                  = var.existing_network_anchor == null ? 0 : 1
  type                   = "Oracle.Database/networkAnchors@2025-09-01"
  resource_id            = local.selected_network_anchor_id
  response_export_values = ["properties", "zones"]

  lifecycle {
    postcondition {
      condition     = lower(self.location) == lower(var.location) && contains(self.output.zones, var.availability_zone)
      error_message = "The selected Network Anchor must match the deployment region and Azure logical availability zone."
    }
    postcondition {
      condition     = try(lower(self.output.properties.provisioningState) == "succeeded", false)
      error_message = "The selected Network Anchor must be successfully provisioned before allocating Exadata capacity."
    }
    postcondition {
      condition = try(
        can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Oracle\\.Database/resourceAnchors/[a-z0-9-]{3,24}$", self.output.properties.resourceAnchorId)) &&
        lower(split("/", self.output.properties.resourceAnchorId)[2]) == lower(var.subscription_id) &&
        lower(split("/", self.output.properties.resourceAnchorId)[4]) == lower(var.resource_group_name), false
      )
      error_message = "The Network Anchor must reference the shared Resource Anchor in the deployment resource group and subscription."
    }
    postcondition {
      condition = try(alltrue([
        for id in [self.output.properties.subnetId, self.output.properties.vnetId] :
        lower(join("/", slice(split("/", id), 0, 5))) == lower("/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}")
      ]), false)
      error_message = "The Network Anchor's subnet and VNet must be in the deployment resource group and subscription."
    }
    postcondition {
      condition     = var.existing_resource_anchor == null ? true : lower(self.output.properties.resourceAnchorId) == lower(local.selected_resource_anchor_id)
      error_message = "The supplied Resource Anchor selector does not match the Resource Anchor associated with the Network Anchor."
    }
  }
}

data "azapi_resource" "resource_anchor" {
  count                  = var.existing_resource_anchor != null || var.existing_network_anchor != null ? 1 : 0
  type                   = "Oracle.Database/resourceAnchors@2025-09-01"
  resource_id            = var.existing_network_anchor != null ? data.azapi_resource.network_anchor[0].output.properties.resourceAnchorId : local.selected_resource_anchor_id
  response_export_values = ["properties"]

  lifecycle {
    postcondition {
      condition     = lower(join("/", slice(split("/", self.id), 0, 5))) == lower("/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}")
      error_message = "The selected Resource Anchor must be in the deployment resource group and subscription."
    }
    postcondition {
      condition     = try(lower(self.output.properties.provisioningState) == "succeeded", false)
      error_message = "The selected Resource Anchor must be successfully provisioned before allocating Exadata capacity."
    }
  }
}

resource "azurerm_virtual_network" "this" {
  count               = local.create_network ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "oracle" {
  count                = local.create_network ? 1 : 0
  name                 = var.delegated_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.delegated_subnet_address_prefix]
  delegation {
    name = "oracle-database"
    service_delegation {
      name = "Oracle.Database/networkAttachments"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

module "resource_anchor" {
  count             = var.existing_resource_anchor == null && var.existing_network_anchor == null ? 1 : 0
  source            = "../../modules/azapi-ora-resource-anchor"
  resource_group_id = local.resource_group_id
  name              = var.resource_anchor_name
  tags              = var.tags
}

module "network_anchor" {
  count                 = var.existing_network_anchor == null ? 1 : 0
  source                = "../../modules/azapi-ora-network-anchor"
  resource_group_id     = local.resource_group_id
  resource_anchor_id    = local.resource_anchor_id
  subnet_id             = local.subnet_id
  name                  = var.network_anchor_name
  location              = var.location
  availability_zone     = var.availability_zone
  oci_vcn_dns_label     = var.oci_vcn_dns_label
  oci_backup_cidr_block = var.oci_backup_cidr_block
  dns                   = var.dns
  tags                  = var.tags
}

module "infrastructure" {
  source               = "../../modules/azapi-ora-exadata-infra"
  resource_group_id    = local.resource_group_id
  resource_anchor_id   = local.resource_anchor_id
  name                 = var.infrastructure.name
  shape                = var.infrastructure.shape
  compute_count        = var.infrastructure.compute_count
  storage_count        = var.infrastructure.storage_count
  database_server_type = var.infrastructure.database_server_type
  storage_server_type  = var.infrastructure.storage_server_type
  location             = var.location
  availability_zone    = var.availability_zone
  tags                 = var.tags

  # Finish anchor creation or validated lookup before allocating paid capacity.
  # This module contains only the managed infrastructure resource, not data reads.
  depends_on = [module.network_anchor, data.azapi_resource.network_anchor, data.azapi_resource.resource_anchor]
}

module "vm_cluster" {
  source                          = "../../modules/azapi-ora-exadata-vmc"
  resource_group_id               = local.resource_group_id
  resource_anchor_id              = local.resource_anchor_id
  network_anchor_id               = local.network_anchor_id
  cloud_exadata_infrastructure_id = module.infrastructure.id
  name                            = var.vm_cluster_name
  location                        = var.location
  availability_zone               = var.availability_zone
  # These known IDs keep immutable network values stable if the created anchor's
  # mutable properties change; the VM module verifies them against the anchor.
  network_ids = var.existing_network_anchor == null ? {
    subnet_id = local.subnet_id
    vnet_id   = local.vnet_id
  } : null
  discover_db_servers         = true
  db_servers                  = var.db_servers
  db_server_count             = var.db_server_count
  hostname                    = var.hostname
  gi_version                  = var.gi_version
  ssh_public_keys             = var.ssh_public_keys
  cpu_core_count              = var.cpu_core_count
  memory_size_in_gbs          = var.memory_size_in_gbs
  db_node_storage_size_in_gbs = var.db_node_storage_size_in_gbs
  data_storage_size_in_tbs    = var.data_storage_size_in_tbs
  data_storage_percentage     = var.data_storage_percentage
  license_model               = var.license_model
  time_zone                   = var.time_zone
  is_local_backup_enabled     = var.is_local_backup_enabled
  is_sparse_diskgroup_enabled = var.is_sparse_diskgroup_enabled
  data_collection_options     = var.data_collection_options
  tags                        = var.tags
}
