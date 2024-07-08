
output "federation_metadata_xml" {
  value = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_application.application.client_id}"
}

output "az_ad_app_object_id" {
  value = azuread_service_principal.application.object_id
}
