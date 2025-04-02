# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI Authentication
variable "oci_config_file_profile" {
  type        = string
  default     = "DEFAULT"
  description = "OCI Config file name"
}

variable "oci_tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
}
variable "oci_user_ocid" {
  type        = string
  description = "OCID of the OCI user"

}
variable "oci_private_key_path" {
  type        = string
  description = "The path (including filename) of the private key"

}
variable "oci_private_key_password" {
  type        = string
  description = "Passphrase used for the key, if it's encrypted"
  sensitive   = true
  default     = null
}

variable "oci_fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used"
}

variable "oci_home_region" {
  type        = string
  description = "OCI Home Region"
}

variable "oci_resource_region" {
  type        = string
  description = "OCI Region for provisioning resources"
}

# For Recovery Services - IAM Policies
variable "recovery_service_admin_grps" {
  type        = string
  description = "List of groups be granted recovery-service admin permission"
  default     = "odbaa-db-family-administrators, odbaa-exa-cdb-administrators"
}

# For NSG rules
variable "backup_network_nsg_id" {
  type        = string
  description = "OCID of the NSG of backup subnet (required when multiple backup NSGs are associated with the VM Cluster)"
  default     = ""
}

variable "client_network_nsg_id" {
  type        = string
  description = "OCID of the NSG of client subnet (required when multiple client NSGs are associated with the VM Cluster)"
  default     = ""
}

# For Container DB
variable "db_home_id" {
  description = "The DB Home OCID"
  type        = string
}

variable "admin_password" {
  description = "admin password for the database"
  type        = string
  sensitive   = true
}
