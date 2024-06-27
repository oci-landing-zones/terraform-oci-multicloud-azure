locals {
  group_prefix = var.group_prefix == "" ? "" : "${var.group_prefix}-"
  adbs_rbac    = contains(["adbs", "all"], var.rbac)
  exa_rbac     = contains(["exa", "all"], var.rbac)
}


#----
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

#-- sso below

module "oci_domain" {
  depends_on = [module.rbac_setup]
  source     = "../../modules/oci-identity/oci-identity-domain"
  providers = {
    oci = oci.oci-st
  }
  compartment_ocid    = var.compartment_ocid
  config_file_profile = var.config_file_profile
  region              = var.region
  domain_display_name = var.domain_display_name
}

module "az_ad" {
  depends_on = [module.oci_domain]
  source     = "../../modules/azure-identity/azure-ad"
  providers = {
    azuread = azuread.az-ad
    azurerm = azurerm.az-rm
  }
  application_name       = var.az_application_name
  oci_domain_uri         = module.oci_domain.domain_url
  user_email             = var.user_email
  application_group_name = var.application_group_name
}

module "oci_idp" {
  depends_on = [module.az_ad]
  source     = "../../modules/oci-identity/oci-identity-provider"
  providers = {
    oci = oci.oci-st
  }
  config_file_profile   = var.config_file_profile
  region                = var.region
  default_rule_id       = var.default_rule_id
  idp_name              = var.idp_name
  oci_domain_url        = module.oci_domain.domain_url
  az_federation_xml_url = module.az_ad.federation_metadata_xml
}

module "az_id_lifecycle" {
  depends_on = [module.oci_idp]
  source     = "../../modules/azure-identity/azure-id-lifecycle"
  providers = {
    azuread = azuread.az-ad
  }
  az_ad_app_object_id               = module.az_ad.az_ad_app_object_id
  oci_confidential_app_secret_token = module.oci_domain.oci_confidential_app_secret_token
  oci_domain_identity_admin_url     = module.oci_domain.oci_domain_identity_admin_url
}

