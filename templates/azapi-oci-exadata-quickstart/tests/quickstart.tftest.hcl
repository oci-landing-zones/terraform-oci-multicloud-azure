mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-workload"
    }
  }
}
mock_provider "azapi" {
  mock_data "azapi_resource" {
    defaults = {
      location = "eastus"
      output = {
        zones = ["1"]
        properties = {
          resourceAnchorId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-anchor/providers/Oracle.Database/resourceAnchors/ra-oradb"
          vnetId           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-oradb"
          subnetId         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-oradb/subnets/oracle"
          ocid             = "ocid1.cloudexadatainfrastructure.oc1..example"
        }
      }
    }
  }
}

variables {
  subscription_id    = "00000000-0000-0000-0000-000000000000"
  location           = "eastus"
  availability_zone  = "1"
  resource_anchor_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-anchor/providers/Oracle.Database/resourceAnchors/ra-oradb"
  network_anchor_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-anchor/providers/Oracle.Database/networkAnchors/na-oradb"
  hostname           = "oradb"
  gi_version         = "19.0.0.0"
  ssh_public_keys    = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQExampleOnly"]
  cpu_core_count     = 4
}

run "new_infrastructure_and_cluster" {
  command = plan
  assert {
    condition     = azapi_resource.infrastructure[0].type == "Oracle.Database/cloudExadataInfrastructures@2026-06-01" && azapi_resource.vm_cluster.type == "Oracle.Database/cloudVmClusters@2026-06-01"
    error_message = "Both resources must use the stable API with Exadata anchor support."
  }
  assert {
    condition     = azapi_resource.infrastructure[0].body.properties.resourceAnchorId == var.resource_anchor_id && azapi_resource.vm_cluster.body.properties.resourceAnchorId == var.resource_anchor_id && azapi_resource.vm_cluster.body.properties.networkAnchorId == var.network_anchor_id
    error_message = "Both resources must use the selected Resource Anchor, with the Network Anchor on the VM cluster."
  }
  assert {
    condition     = azapi_resource.vm_cluster.body.properties.vnetId == data.azapi_resource.network_anchor.output.properties.vnetId && azapi_resource.vm_cluster.body.properties.subnetId == data.azapi_resource.network_anchor.output.properties.subnetId && !contains(keys(azapi_resource.vm_cluster.body.properties), "backupSubnetCidr") && !contains(keys(azapi_resource.vm_cluster.body), "zones") && !contains(keys(azapi_resource.vm_cluster.body.properties), "zoneId")
    error_message = "Required networking must come from the anchor; backup networking is owned by the anchor."
  }
}

run "reuse_infrastructure" {
  command = plan
  variables {
    create_resource_group                    = true
    existing_cloud_exadata_infrastructure_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-capacity/providers/Oracle.Database/cloudExadataInfrastructures/exadata-existing"
  }
  assert {
    condition     = length(azapi_resource.infrastructure) == 0 && length(azurerm_resource_group.this) == 1 && azapi_resource.vm_cluster.body.properties.cloudExadataInfrastructureId == var.existing_cloud_exadata_infrastructure_id
    error_message = "Existing capacity must be referenced, never created or managed."
  }
}

run "reject_invalid_cluster_inputs" {
  command = plan
  variables {
    hostname        = "invalid_hostname"
    license_model   = "BRING_YOUR_OWN_LICENSE"
    cpu_core_count  = 0
    ssh_public_keys = ["private-key-or-path"]
  }
  expect_failures = [var.hostname, var.license_model, var.cpu_core_count, var.ssh_public_keys]
}

run "reject_mismatched_network_anchor" {
  command = plan
  variables {
    availability_zone = "2"
  }
  expect_failures = [azapi_resource.vm_cluster]
}
