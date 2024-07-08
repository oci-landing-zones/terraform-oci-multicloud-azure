
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
}

# 5. Additional  configuration for federated users #########
locals {
  sso_service_principal_id = data.azuread_service_principal.sso_app.id
  # extracting <job_id> from value  "<principal_id>/job/<job_id>"
  sso_provision_job_id = split("/", azuread_synchronization_job.provision_job.id)[2]
}


# # # # Step 5 mapping changes # # # # 
resource "terraform_data" "azad_sync_job_schema_modify" {
  depends_on = [
    azuread_synchronization_job.provision_job
  ]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "pip3 install -r scripts/requirements.txt"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "python3 scripts/azad_sync_job_schema_modify.py -sp '${local.sso_service_principal_id}' -pj '${local.sso_provision_job_id}' "
  }
} 