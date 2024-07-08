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
  identifier_uri          = "${var.oci_domain_uri}/fed"
  redirect_uris           = ["${var.oci_domain_uri}/fed/v1/sp/sso"]
  login_url               = "${var.oci_domain_uri}/ui/v1/myconsole"
  application_template_id = "8ac83ca1-af23-41f3-a342-0118ab26754c"
}
data "azuread_client_config" "current" {}

resource "azuread_application" "application" {
  display_name = var.application_name
  # Can't set identifier uris before a token signing certificate associated with a service principal. 
  # Got unexpected status 400 with OData error: HostNameNotOnVerifiedDomain: Values of identifierUris property 
  # must use a verified domain of the organization or its subdomain.
  # identifier_uris = var.identifier_uris
  prevent_duplicate_names = false
  template_id             = local.application_template_id

  web {
    redirect_uris = local.redirect_uris
  }

  feature_tags {
    enterprise            = true
    gallery               = true
    custom_single_sign_on = true
  }

  lifecycle {
    ignore_changes = [
      identifier_uris,
    ]
  }
}

resource "azuread_service_principal" "application" {
  client_id    = azuread_application.application.client_id
  use_existing = true
  # app_role_assignment_required  = true
  # use_existing                  = true
  preferred_single_sign_on_mode = "saml"
  login_url                     = local.login_url
  # feature_tags {
  #   enterprise            = true
  #   gallery               = false
  #   custom_single_sign_on = true
  # }
}

resource "azuread_service_principal_token_signing_certificate" "odbaa_sp_token_signing_certificate" {
  service_principal_id = azuread_service_principal.application.id
  display_name         = "CN=OCIcloudMSFT"
  end_date             = "2027-01-22T00:00:00Z"
}

resource "azuread_application_identifier_uri" "identifier_uri" {
  application_id = azuread_application.application.id
  identifier_uri = local.identifier_uri
  depends_on     = [azuread_service_principal_token_signing_certificate.odbaa_sp_token_signing_certificate]
}

data "http" "idp_metadata" {
  url = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_application.application.client_id}"
  request_headers = {
    Accept = "application/xml"
  }
  depends_on = [
    azuread_service_principal.application,
    azuread_application.application
  ]
}

resource "azuread_claims_mapping_policy" "odbaa_mapping_policy" {
  count = var.claim ? 1 : 0
  definition = [
    jsonencode(
      {
        ClaimsMappingPolicy = {
          ClaimsSchema = [
            {
              samlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname",
              source        = "User",
              id            = "givenname",
            },
            {
              samlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname",
              source        = "User",
              id            = "surname",
            },
            {
              samlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
              source        = "User",
              id            = "mail"
            },
            {
              samlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
              source        = "User",
              id            = "userprincipalname"
            },
            {
              samlClaimType    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",
              samlNameIdFormat = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
              source           = "user",
              id               = "mail",
            }
          ]
          IncludeBasicClaimSet = "true"
          Version              = 1
        }
      }
    )
  ]
  display_name = "odbaa_mapping_policy"
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "app" {
  claims_mapping_policy_id = one(azuread_claims_mapping_policy.odbaa_mapping_policy).id
  service_principal_id     = azuread_service_principal.application.id

}


data "azuread_user" "user" {
  count = var.user_email == "" ? 0 : 1
  # only one of `employee_id,mail,mail_nickname,object_id,user_principal_name` can be specified
  mail = var.user_email
}

resource "azuread_group" "app_group" {
  count            = var.application_group_name != "" ? 1 : 0
  display_name     = var.application_group_name
  security_enabled = true
  members = length(data.azuread_user.user) > 0 ? [
    /* more users */
    one(data.azuread_user.user).object_id
  ] : []
}

resource "azuread_app_role_assignment" "app_role_assignment" {
  count               = var.application_group_name == "" ? 0 : 1
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  principal_object_id = data.azuread_user.user == null ? "" : one(azuread_group.app_group).object_id
  resource_object_id  = azuread_service_principal.application.object_id
}

