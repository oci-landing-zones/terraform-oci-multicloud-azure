
terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      # version = "~> 2.48.0" # -- for module local run  -- uncomment
    }
  }
}

# -- for module local run  -- uncomment start 
# provider "azuread" {
# }
# -- uncomment end

data "azuread_service_principal" "sso_app" {
  object_id = var.az_ad_app_object_id
}

# 3. Create OCI application on Azure AD
resource "azuread_synchronization_secret" "provision_secret" {
  service_principal_id = data.azuread_service_principal.sso_app.id

  credential {
    key   = "BaseAddress"
    value = var.oci_domain_identity_admin_url
  }
  credential {
    key   = "SecretToken"
    value = var.oci_confidential_app_secret_token
  }
}

resource "azuread_synchronization_job" "provision_job" {
  service_principal_id = data.azuread_service_principal.sso_app.id
  template_id          = "oracleIDCS"
  enabled              = true

  provisioner "local-exec" {
    when = create
    interpreter = ["/bin/bash","-c"]
    working_dir = path.module
    command     = <<EOT
      export AZ_TOKEN=$(az account get-access-token --resource-type ms-graph | jq -r .accessToken)
      python3 -m venv .venv
      . .venv/bin/activate
      .venv/bin/pip install -r scripts/requirements.txt
      python3 scripts/azad_sync_job_schema_modify.py -sp '${data.azuread_service_principal.sso_app.id}' -pj '${split("/", azuread_synchronization_job.provision_job.id)[2]}'
EOT
  }
}