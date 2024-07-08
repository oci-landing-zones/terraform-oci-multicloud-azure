locals {
  group_prefix = var.group_prefix == "" ? "" : "${var.group_prefix}-"
  adbs_rbac    = contains(["adbs", "all"], var.rbac)
  exa_rbac     = contains(["exa", "all"], var.rbac)

}

module "rbac_setup" {
  source = "../../modules/azure-identity"
  providers = {
    azuread = azuread.az-ad
    azurerm = azurerm.az-rm
  }
  group_prefix = local.group_prefix
  exa_rbac     = local.exa_rbac
  adbs_rbac    = local.adbs_rbac
}