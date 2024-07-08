##########################################################################################################
# Copyright (c) 2022,2023 Oracle and/or its affiliates, All rights reserved.                             #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
##########################################################################################################

# -----------------------------------------------------------------------------
# Required inputs
# -----------------------------------------------------------------------------
variable "vm_cluster_ocid" {
  type        = string
  description = "The OCID of the VM Cluster"
}

variable "db_home_display_name" {
  type        = string
  description = "The display name of the DB Home"
}

variable "db_admin_password" {
  type        = string
  description = "A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -."
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "pdb_name" {
  type        = string
  description = "The name of the pluggable database"
}

variable "region" {
  type        = string
  description = "The region name on the OCI, e.g. us-ashburn-1"
}

variable "db_home_source" {
  type        = string
  description = "The source of database. For Exadata VM Cluster, use VM_CLUSTER_NEW"
}

variable "db_version" {
  type        = string
  description = "A valid Oracle Database version. e.g. 19.20.0.0"
}

variable "db_source" {
  type        = string
  description = "The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup. "
}
