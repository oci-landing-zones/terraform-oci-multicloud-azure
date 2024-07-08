
variable "az_ad_app_object_id" {
  description = "objectId of azure enterprise app created for sso"
}

variable "oci_confidential_app_secret_token" {
  description = "oci confidential app secret token , base64 encode of client-id:client-secret"
}

variable "oci_domain_identity_admin_url" {
  description = "admin domain url e.g. https://idcs-<>.identity.oraclecloud.com:443/admin/v1"
}

