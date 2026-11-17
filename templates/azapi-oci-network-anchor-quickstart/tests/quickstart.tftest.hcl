mock_provider "azapi" {}
mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-network"
    }
  }
}

variables {
  subscription_id   = "00000000-0000-0000-0000-000000000000"
  location          = "eastus"
  availability_zone = "1"
}

run "new_foundation" {
  command = plan

  assert {
    condition     = azapi_resource.network_anchor.type == "Oracle.Database/networkAnchors@2025-09-01" && azapi_resource.resource_anchor[0].type == "Oracle.Database/resourceAnchors@2025-09-01"
    error_message = "Anchors must use the stable 2025-09-01 API."
  }
  assert {
    condition     = azapi_resource.network_anchor.body.zones == ["1"] && azapi_resource.network_anchor.body.properties.ociVcnDnsLabel == "oradb"
    error_message = "The requested zone and default DNS label must be sent."
  }
  assert {
    condition     = !contains(keys(azapi_resource.network_anchor.body.properties), "dnsForwardingRules") && !contains(keys(azapi_resource.network_anchor.body.properties), "ociBackupCidrBlock")
    error_message = "Unset optional properties must be absent, not null."
  }
  assert {
    condition     = azurerm_subnet.oracle[0].delegation[0].service_delegation[0].name == "Oracle.Database/networkAttachments"
    error_message = "The subnet must use the Oracle networkAttachments delegation."
  }
}

run "reuse_foundation_with_dns" {
  command = plan

  variables {
    create_resource_group       = false
    create_network              = false
    existing_subnet_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/oracle"
    existing_resource_anchor_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-network/providers/Oracle.Database/resourceAnchors/resource-anchor"
    oci_backup_cidr_block       = "192.168.252.0/24"
    dns = {
      listening_endpoint_enabled       = true
      listening_endpoint_allowed_cidrs = ["10.1.0.0/24", "10.2.0.0/24"]
      forwarding_endpoint_enabled      = true
      forwarding_rules = [{
        domain_names          = ["one.example.com", "two.example.com"]
        forwarding_ip_address = "10.3.0.4"
      }]
    }
  }

  assert {
    condition     = length(azurerm_resource_group.this) == 0 && length(azurerm_virtual_network.this) == 0 && length(azurerm_subnet.oracle) == 0 && length(azapi_resource.resource_anchor) == 0
    error_message = "Existing foundations must not be recreated or managed."
  }
  assert {
    condition     = azapi_resource.network_anchor.body.properties.resourceAnchorId == var.existing_resource_anchor_id && output.subnet_id == var.existing_subnet_id
    error_message = "The selected existing IDs must be used."
  }
  assert {
    condition     = azapi_resource.network_anchor.body.properties.dnsListeningEndpointAllowedCidrs == "10.1.0.0/24,10.2.0.0/24" && azapi_resource.network_anchor.body.properties.dnsForwardingRules[0].domainNames == "one.example.com,two.example.com"
    error_message = "DNS CIDR and domain lists must be serialized as comma-separated strings."
  }
}

run "reject_missing_existing_subnet" {
  command = plan
  variables {
    create_network = false
  }
  expect_failures = [var.existing_subnet_id]
}

run "reject_invalid_name_and_cidr" {
  command = plan
  variables {
    network_anchor_name             = "invalid_name"
    delegated_subnet_address_prefix = "10.20.1.0/28"
    oci_backup_cidr_block           = "not-a-cidr"
  }
  expect_failures = [var.network_anchor_name, var.delegated_subnet_address_prefix, var.oci_backup_cidr_block]
}

run "reject_dns_rule_without_endpoint" {
  command = plan
  variables {
    dns = {
      forwarding_rules = [{
        domain_names          = ["example.com"]
        forwarding_ip_address = "10.3.0.4"
      }]
    }
  }
  expect_failures = [var.dns]
}
