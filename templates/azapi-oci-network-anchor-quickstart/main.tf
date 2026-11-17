locals {
  resource_group_id   = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  subnet_id           = var.create_network ? azurerm_subnet.oracle[0].id : var.existing_subnet_id
  resource_anchor_id  = var.existing_resource_anchor_id == null ? azapi_resource.resource_anchor[0].id : var.existing_resource_anchor_id

  # AzAPI v2 takes HCL objects. Omit unset optional properties rather than sending null.
  network_anchor_optional_properties = {
    ociVcnDnsLabel                       = var.oci_vcn_dns_label
    ociBackupCidrBlock                   = var.oci_backup_cidr_block
    isOracleToAzureDnsZoneSyncEnabled    = var.dns.zone_sync_enabled
    isOracleDnsListeningEndpointEnabled  = var.dns.listening_endpoint_enabled
    isOracleDnsForwardingEndpointEnabled = var.dns.forwarding_endpoint_enabled
    dnsListeningEndpointAllowedCidrs     = length(var.dns.listening_endpoint_allowed_cidrs) > 0 ? join(",", var.dns.listening_endpoint_allowed_cidrs) : null
    dnsForwardingRules = length(var.dns.forwarding_rules) > 0 ? [for rule in var.dns.forwarding_rules : {
      domainNames         = join(",", rule.domain_names)
      forwardingIpAddress = rule.forwarding_ip_address
    }] : null
  }
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

resource "azurerm_virtual_network" "this" {
  count               = var.create_network ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "oracle" {
  count                = var.create_network ? 1 : 0
  name                 = var.delegated_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.delegated_subnet_address_prefix]

  delegation {
    name = "oracle-database"
    service_delegation {
      name    = "Oracle.Database/networkAttachments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azapi_resource" "resource_anchor" {
  count     = var.existing_resource_anchor_id == null ? 1 : 0
  type      = "Oracle.Database/resourceAnchors@2025-09-01"
  name      = var.resource_anchor_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags
  body = {
    properties = {}
  }
}

resource "azapi_resource" "network_anchor" {
  # These properties are create-only in the Oracle API. Keep mutable backup
  # CIDR and DNS enablement flags out of the replacement triggers.
  replace_triggers_external_values = {
    zone               = var.availability_zone
    resource_anchor_id = local.resource_anchor_id
    subnet_id          = local.subnet_id
    vcn_dns_label      = var.oci_vcn_dns_label
    forwarding_rules   = var.dns.forwarding_rules
    listening_cidrs    = var.dns.listening_endpoint_allowed_cidrs
  }

  type      = "Oracle.Database/networkAnchors@2025-09-01"
  name      = var.network_anchor_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    zones = [var.availability_zone]
    properties = merge({
      resourceAnchorId = local.resource_anchor_id
      subnetId         = local.subnet_id
    }, { for key, value in local.network_anchor_optional_properties : key => value if value != null })
  }
}
