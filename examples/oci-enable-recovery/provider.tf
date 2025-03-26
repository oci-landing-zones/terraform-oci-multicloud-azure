provider "oci" {
  alias                = "home"
  region               = "us-ashburn-1"
  auth                 = "APIKey"
  tenancy_ocid         = var.oci_tenancy_ocid
  user_ocid            = var.oci_user_ocid
  fingerprint          = var.oci_fingerprint
  private_key_path     = var.oci_private_key_path
  private_key_password = var.oci_private_key_password
}

provider "oci" {
  alias                = "resource"
  region               = "uk-london-1"
  auth                 = "APIKey"
  tenancy_ocid         = var.oci_tenancy_ocid
  user_ocid            = var.oci_user_ocid
  fingerprint          = var.oci_fingerprint
  private_key_path     = var.oci_private_key_path
  private_key_password = var.oci_private_key_password
}
