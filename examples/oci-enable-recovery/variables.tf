# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI Authentication
variable "oci_config_file_profile" {
  type        = string
  default     = "DEFAULT"
  description = "OCI Config file name"
}

variable oci_tenancy_ocid {
  type        = string
  description = "OCID of the OCI tenancy"
}
variable oci_user_ocid {
  type        = string
  description = "OCID of the OCI user"

}
variable oci_private_key_path {
  type        = string
  description = "The path (including filename) of the private key"

}
variable oci_private_key_password {
  type        = string
  description = "Passphrase used for the key, if it's encrypted"
  sensitive   = true
  default = null
}

variable oci_fingerprint {
  type        = string
  description = "Fingerprint for the key pair being used"
}

variable "oci_region" {
  type = string
  description = "OCI Region"
}

variable recovery_service_admin_grps {
    description = "List of groups be granted recovery-service admin permission"
    default = "odbaa-db-family-administrators, odbaa-exa-cdb-administrators"
}

variable "database_id" {
  description = "The database OCID"
  type = string
}

variable "db_home_id" {
  description = "The DB Home OCID"
  type = string
}
