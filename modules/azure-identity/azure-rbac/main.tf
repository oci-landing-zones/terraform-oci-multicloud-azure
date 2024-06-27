terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
locals {
  # needs Built-in Azure Role assigned
  odbaa_built_in_role_assigned_groups = var.odbaa_built_in_role_assigned_groups
  # doesn't need Built-in Azure Role assigned
  odbaa_other_groups    = var.odbaa_other_groups
  group_to_role_mapping = var.role_mapping
}

data "azurerm_subscription" "primary" {
}

resource "azuread_group" "odbaa-required-azure-role-assignment-group" {
  display_name     = each.key
  security_enabled = true
  for_each         = local.odbaa_built_in_role_assigned_groups
}

resource "azurerm_role_assignment" "rbac-role-assignment" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = local.group_to_role_mapping[each.value.display_name]
  principal_id         = each.value.object_id
  for_each             = azuread_group.odbaa-required-azure-role-assignment-group
}

resource "azuread_group" "odbaa-other-group" {
  display_name     = each.key
  security_enabled = true
  for_each         = local.odbaa_other_groups
}