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

  odbaa_adbs_db_administrator_group    = "${var.group_prefix}odbaa-adbs-db-administrators-group"
  odbaa_exa_infra_administrator_group  = "${var.group_prefix}odbaa-exa-infra-administrator"
  odbaa_vm_cluster_administrator_group = "${var.group_prefix}odbaa-vm-cluster-administrator"
  odbaa_db_family_administrators_group = "${var.group_prefix}odbaa-db-family-administrators"
  odbaa_db_family_readers_group        = "${var.group_prefix}odbaa-db-family-readers"
  odbaa_exa_cdb_administrators_group   = "${var.group_prefix}odbaa-exa-cdb-administrators"
  odbaa_exa_pdb_administrators_group   = "${var.group_prefix}odbaa-exa-pdb-administrators"
  odbaa_costmgmt_administrators_group  = "${var.group_prefix}odbaa-costmgmt-administrators"
  odbaa_network_administrators_group   = "${var.group_prefix}odbaa-network-administrators"
  # odbaa_other_group includes groups doesn't need build in Azure role assigned.
  odbaa_other_groups = toset(compact(["${local.odbaa_costmgmt_administrators_group}", "${local.odbaa_network_administrators_group}", "${local.odbaa_exa_cdb_administrators_group}", "${local.odbaa_exa_pdb_administrators_group}"]))
  group_to_role_mapping = tomap({
    "${local.odbaa_adbs_db_administrator_group}"    = var.adbs_rbac ? "${one(azurerm_role_definition.odbaa-adbs-db-administrators-role).name}" : ""
    "${local.odbaa_exa_infra_administrator_group}"  = "Oracle.Database Exadata Infrastructure Administrator Built-in Role"
    "${local.odbaa_vm_cluster_administrator_group}" = "Oracle.Database VmCluster Administrator Built-in Role"
    "${local.odbaa_db_family_administrators_group}" = "Oracle.Database Owner Built-in Role"
    "${local.odbaa_db_family_readers_group}"        = "Oracle.Database Reader Built-in Role"
  })
  odbaa_adbs_groups = var.adbs_rbac ? compact(["${local.odbaa_db_family_administrators_group}", "${local.odbaa_db_family_readers_group}", "${local.odbaa_adbs_db_administrator_group}"]) : []
  odbaa_exa_groups  = var.exa_rbac ? compact(["${local.odbaa_db_family_administrators_group}", "${local.odbaa_db_family_readers_group}", "${local.odbaa_exa_infra_administrator_group}", "${local.odbaa_vm_cluster_administrator_group}"]) : []
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "odbaa-adbs-db-administrators-role" {
  count       = var.adbs_rbac ? 1 : 0
  name        = "Oracle.Database Autonomous Database Administrator"
  scope       = data.azurerm_subscription.primary.id
  description = "Grants full access to manage all ADB-S resources"

  permissions {
    actions = [
      "Oracle.Database/autonomousDatabases/*/read",
      "Oracle.Database/autonomousDatabases/*/write",
      "Oracle.Database/autonomousDatabases/*/delete",
      "Oracle.Database/Locations/*/read",
      "Oracle.Database/Locations/*/write",
      "Oracle.Database/Operations/read",
      "Oracle.Database/oracleSubscriptions/*/read",
      "Oracle.Database/oracleSubscriptions/*/action",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/locations/*/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/*"
    ]
    data_actions     = []
    not_actions      = []
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

module "azure_rbac_setup" {
  source                              = "./azure-rbac"
  odbaa_built_in_role_assigned_groups = toset(concat(local.odbaa_adbs_groups, local.odbaa_exa_groups))
  odbaa_other_groups                  = local.odbaa_other_groups
  role_mapping                        = local.group_to_role_mapping
}