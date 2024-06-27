terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      # version = ">= 5.0.0"# -- for local module run
    }
  }
}

# uncomment below for local module run -- start
# provider "oci" {
#   auth                = "SecurityToken"
#   config_file_profile = var.config_file_profile
#   region              = var.region
# }
# uncomment -- end

# https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_domains
data "oci_identity_domains" "list_domain" {
  #Required
  compartment_id = var.compartment_ocid
  display_name   = var.domain_display_name
}

locals {
  oci_domain_url = data.oci_identity_domains.list_domain.domains[0].url
}



# https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_domains_setting
data "oci_identity_domains_setting" "domain_setting" {
  #Required
  idcs_endpoint = local.oci_domain_url
  setting_id    = "Settings"

  #Optional
  attribute_sets = ["all"]
}


# https://registry.terraform.io/providers/oracle/oci/5.40.0/docs/resources/identity_domains_setting
resource "oci_identity_domains_setting" "domain_setting" {
  #Required
  csr_access    = "readWrite"
  idcs_endpoint = local.oci_domain_url
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:Settings"]
  setting_id    = "Settings"

  # Optional
  attribute_sets             = ["all"]
  signing_cert_public_access = true
  # to counter auto-updates
  contact_emails                        = data.oci_identity_domains_setting.domain_setting.contact_emails
  custom_branding                       = data.oci_identity_domains_setting.domain_setting.custom_branding
  locale                                = data.oci_identity_domains_setting.domain_setting.locale
  service_admin_cannot_list_other_users = data.oci_identity_domains_setting.domain_setting.service_admin_cannot_list_other_users
  timezone                              = data.oci_identity_domains_setting.domain_setting.timezone

}


# -- - below this is for user identity federation ---- 
# Following 1 & 2 of https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/lifecycle_azure/01-config-azure-template.htm
# -- - - -- - --   - -- -  - - - - -- - - - - - - -- - - - - 


# Create confidential application 
#https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_domains_app
resource "oci_identity_domains_app" "confidential_app" {

  based_on_template {
    value         = "CustomWebAppTemplateId"
    well_known_id = "CustomWebAppTemplateId"
  }
  display_name  = var.confidential_app_name
  description   = "Confidential application for identity federation provisioning"
  idcs_endpoint = local.oci_domain_url
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:App"]
  active        = true

  #allow_offline = false
  client_type     = "confidential"
  allowed_grants  = ["client_credentials"]
  is_oauth_client = true
  trust_scope     = "Explicit"
  login_mechanism = "OIDC"
}

locals {
  confid_app_client_id     = oci_identity_domains_app.confidential_app.name
  confid_app_client_secret = oci_identity_domains_app.confidential_app.client_secret
}


# Get Role 
#https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_domains_app_roles
data "oci_identity_domains_app_roles" "get_app_role_useradmin" {
  #Required
  idcs_endpoint   = local.oci_domain_url
  app_role_filter = "(displayName eq \"User Administrator\")"
}

locals {
  user_admin_approles     = data.oci_identity_domains_app_roles.get_app_role_useradmin.app_roles[0]
  user_admin_approles_app = data.oci_identity_domains_app_roles.get_app_role_useradmin.app_roles[0].app[0]
}


# Grant Role tp App
# https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_domains_grant
resource "oci_identity_domains_grant" "app_grant_domain_admin" {
  #Required
  grant_mechanism = "ADMINISTRATOR_TO_APP"
  grantee {
    #Required
    type  = "App"
    value = oci_identity_domains_app.confidential_app.id
  }
  idcs_endpoint = local.oci_domain_url
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:Grant"]
  app {
    #Required
    value = local.user_admin_approles_app.value
  }
  entitlement {
    #Required
    attribute_name  = "appRoles"
    attribute_value = local.user_admin_approles.id
  }

  depends_on = [oci_identity_domains_app.confidential_app]
}