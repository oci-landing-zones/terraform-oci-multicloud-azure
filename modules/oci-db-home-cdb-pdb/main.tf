terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_database_db_home" "exa_db_home" {
  source        = var.db_home_source
  vm_cluster_id = var.vm_cluster_ocid
  db_version    = var.db_version
  display_name  = var.db_home_display_name
  enable_database_delete = var.enable_database_delete
}

resource "oci_database_database" "exa_cdb" {
  db_home_id = oci_database_db_home.exa_db_home.id

  database {
    db_name        = var.db_name
    admin_password = var.db_admin_password
  }
  source = var.db_source
}

resource "oci_database_pluggable_database" "exa_pdb" {
  container_database_id = oci_database_database.exa_cdb.id
  pdb_name              = var.pdb_name
  pdb_admin_password    = var.db_admin_password
  tde_wallet_password   = var.db_admin_password
}