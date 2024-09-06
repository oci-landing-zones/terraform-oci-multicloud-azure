terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = ">= 5.0.0"
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

  # Append new SAML identity provider into default IdP policy
  provisioner "local-exec" {
    when = create
    environment = {
      "OCI_CLI_AUTH" : "security_token"
    }
    interpreter = ["/bin/bash","-c"]
    working_dir = path.module
    command     = <<EOT
      python3 -m venv .venv
      . .venv/bin/activate
      .venv/bin/pip install -r scripts/requirements.txt
      python3 scripts/identity_domain_helper.py -o ADD -p '${var.config_file_profile}'  -u '${var.oci_domain_url}' -r '${var.default_rule_id}' -i '${oci_identity_domains_identity_provider.new_saml_idp.id}'
EOT
  }

  # [To-Do: remove the IdP from IdP policy + disable the IdP ]
}

output "new_saml_idp_id" {
  value = oci_identity_domains_identity_provider.new_saml_idp.id
}