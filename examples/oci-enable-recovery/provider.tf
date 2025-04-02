# OCI Home Region for provisioning IAM policies
provider "oci" {
  alias                = "home"
  auth                 = "APIKey"
  region               = var.oci_home_region
  tenancy_ocid         = var.oci_tenancy_ocid
  user_ocid            = var.oci_user_ocid
  fingerprint          = var.oci_fingerprint
  private_key_path     = var.oci_private_key_path
  private_key_password = var.oci_private_key_password
}

# OCI Region for provisioning other cloud resources
provider "oci" {
  alias                = "resource"
  auth                 = "APIKey"
  region               = var.oci_resource_region
  tenancy_ocid         = var.oci_tenancy_ocid
  user_ocid            = var.oci_user_ocid
  fingerprint          = var.oci_fingerprint
  private_key_path     = var.oci_private_key_path
  private_key_password = var.oci_private_key_password
}
