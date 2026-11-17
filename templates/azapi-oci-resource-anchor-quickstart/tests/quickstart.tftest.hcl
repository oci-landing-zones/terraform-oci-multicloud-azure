mock_provider "azapi" {}
mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-oradb-anchor"
    }
  }
}

variables {
  subscription_id = "00000000-0000-0000-0000-000000000000"
  location        = "eastus"
}

run "new_resource_group" {
  command = plan

  assert {
    condition     = length(azurerm_resource_group.this) == 1 && length(data.azurerm_resource_group.this) == 0
    error_message = "The default path must create its resource group."
  }
  assert {
    condition     = azapi_resource.resource_anchor.type == "Oracle.Database/resourceAnchors@2025-09-01" && length(keys(azapi_resource.resource_anchor.body.properties)) == 0
    error_message = "Use the stable Resource Anchor API and send only writable properties."
  }
  assert {
    condition     = azapi_resource.resource_anchor.location == "global" && azapi_resource.resource_anchor.name == var.resource_anchor_name
    error_message = "The Resource Anchor must use the global ARM location and selected name."
  }
}

run "existing_resource_group" {
  command = plan
  variables {
    create_resource_group = false
    tags = {
      workload = "test"
    }
  }

  assert {
    condition     = length(azurerm_resource_group.this) == 0 && azapi_resource.resource_anchor.parent_id == data.azurerm_resource_group.this[0].id && output.resource_group_id == data.azurerm_resource_group.this[0].id
    error_message = "Reuse the selected resource group without managing or recreating it."
  }
  assert {
    condition     = azapi_resource.resource_anchor.tags == var.tags
    error_message = "The Resource Anchor must receive the supplied tags."
  }
}

run "reject_invalid_name_and_subscription" {
  command = plan
  variables {
    resource_anchor_name = "invalid_anchor"
    subscription_id      = "not-a-subscription-id"
  }
  expect_failures = [var.resource_anchor_name, var.subscription_id]
}

run "reject_invalid_resource_group_and_location" {
  command = plan
  variables {
    resource_group_name = "invalid/group"
    location            = " "
  }
  expect_failures = [var.resource_group_name, var.location]
}
