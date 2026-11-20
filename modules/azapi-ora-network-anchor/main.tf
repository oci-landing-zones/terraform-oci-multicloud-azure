locals {
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

resource "azapi_resource" "this" {
  lifecycle {
    # The service can return a VNet-derived DNS label instead of the requested
    # create-time label. Keep the canonical response without perpetual drift.
    # Explicit input changes still replace the anchor through the trigger below.
    ignore_changes = [body.properties.ociVcnDnsLabel]
  }

  # These properties are create-only in the Oracle API. Keep mutable backup
  # CIDR and DNS enablement flags out of the replacement triggers.
  replace_triggers_external_values = {
    zone               = var.availability_zone
    resource_anchor_id = var.resource_anchor_id
    subnet_id          = var.subnet_id
    vcn_dns_label      = var.oci_vcn_dns_label
    forwarding_rules   = var.dns.forwarding_rules
    listening_cidrs    = var.dns.listening_endpoint_allowed_cidrs
  }

  type      = "Oracle.Database/networkAnchors@2025-09-01"
  name      = var.name
  parent_id = var.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    zones = [var.availability_zone]
    properties = merge({
      resourceAnchorId = var.resource_anchor_id
      subnetId         = var.subnet_id
    }, { for key, value in local.network_anchor_optional_properties : key => value if value != null })
  }
}
