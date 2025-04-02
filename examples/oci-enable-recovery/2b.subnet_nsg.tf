# Configuring Recovery Service https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html

locals {
  # NSG Rules for the Recovery Service Private Subnet https://docs.oracle.com/en-us/iaas/recovery-service/doc/getting-started-recovery-service.html#GUID-9CD51C49-117B-4449-8A39-68CE8822E63B
  nsg_rules = [
    # Allow traffic from client subnet to backup subnet
    { direction = "EGRESS", nsg_id = local.client_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 8005 },
    { direction = "EGRESS", nsg_id = local.client_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 2484 },

    { direction = "INGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.client_subnet.cidr_block, port = 8005 },
    { direction = "INGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.client_subnet.cidr_block, port = 2484 },

    # Allow traffic from backup subnet to backup subnet
    { direction = "EGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 8005 },
    { direction = "EGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 2484 },

    { direction = "INGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 8005 },
    { direction = "INGRESS", nsg_id = local.backup_nsg_id, cidr = data.oci_core_subnet.backup_subnet.cidr_block, port = 2484 }, 
  ]
}

resource "oci_core_network_security_group_security_rule" "nsg_rules" {
  provider = oci.resource
  for_each = { for i, rule in local.nsg_rules : i => rule }

  network_security_group_id = each.value.nsg_id
  description               = "Allow traffic for Recovery Service"
  protocol                  = 6 #TCP
  direction                 = each.value.direction

  source_type = each.value.direction == "INGRESS" ? "CIDR_BLOCK" : null
  source      = each.value.direction == "INGRESS" ? each.value.cidr : null

  destination_type = each.value.direction == "EGRESS" ? "CIDR_BLOCK" : null
  destination      = each.value.direction == "EGRESS" ? each.value.cidr : null

  stateless = false
  tcp_options {
    destination_port_range {
      max = tonumber(each.value.port)
      min = tonumber(each.value.port)
    }
  }
}
