
output "sso_service_principal_id" {
  value = data.azuread_service_principal.sso_app.id
}


output "provision_job_id" {
  value = azuread_synchronization_job.provision_job.id
}
