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

# Fetch azure federation metadata url 
data "http" "az_federation_xmldata_http" {
  url = var.az_federation_xml_url
}

locals {
  az_federation_xmldata = replace(data.http.az_federation_xmldata_http.response_body, "\ufeff", "")
}

# Create SAML identity provider 
# https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_domains_identity_provider
resource "oci_identity_domains_identity_provider" "new_saml_idp" {
  #Required
  enabled       = true
  idcs_endpoint = var.oci_domain_url
  partner_name  = var.idp_name
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:IdentityProvider"]
  #Optional but required for our purpose
  description                  = var.idp_description
  type                         = "SAML"
  metadata                     = local.az_federation_xmldata
  signature_hash_algorithm     = "SHA-256"
  user_mapping_method          = "NameIDToUserAttribute"
  user_mapping_store_attribute = "emails.primary"
  name_id_format               = "saml-emailaddress"
}


locals {
  new_saml_idp_id = oci_identity_domains_identity_provider.new_saml_idp.id
}

output "new_saml_idp_id" {
  value = local.new_saml_idp_id
}

resource "terraform_data" "default_policy_rule_update" {
  depends_on = [
    oci_identity_domains_identity_provider.new_saml_idp
  ]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "pip3 install -r scripts/requirements.txt"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "python3 scripts/identity_domain_helper.py -p '${var.config_file_profile}'  -u '${var.oci_domain_url}' -r '${var.default_rule_id}' -i '${local.new_saml_idp_id}'  "
  }
} 