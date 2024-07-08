
output "domain_url" {
  value = data.oci_identity_domains.list_domain.domains[0].url
}

output "domain_metadata_xml_url" {
  value = "${local.oci_domain_url}/fed/v1/metadata"
}

output "oci_domain_identity_admin_url" {
  value = "${local.oci_domain_url}/admin/v1"
}

output "oci_confidential_app_secret_token" {
  value = base64encode("${local.confid_app_client_id}:${local.confid_app_client_secret}")
}
