# https://docs.oracle.com/en-us/iaas/Content/terraform/configuring.htm
provider "oci" {
  auth                 = "APIKey"
  region               = local.oci_region
  tenancy_ocid         = var.oci_tenancy_ocid
  user_ocid            = var.oci_user_ocid
  fingerprint          = var.oci_fingerprint
  private_key_path     = var.oci_private_key_path
  private_key_password = var.oci_private_key_password
  #   config_file_profile  = var.oci_config_file_profile
}

locals {
  # Define OCI Region base on Azure Region   
  oci_region = module.azure-oci-mapping.region_id

  # Assign OCI tags  
  oci_tags = var.common_tags

  # Oracle Database DB Home + Container Database (CDB) with default Pluggable Database (PDB)
  database_db_home = {
        db_home_1 = {
            vm_cluster_id   = module.avm_exadata_vmc.vm_cluster_ocid
            freeform_tags   = local.oci_tags
            db_home_source  = var.db_home_source
            db_home_version = var.db_home_version
            db_home_name    = "${var.db_home_name}${random_string.suffix.result}"
            source          = var.db_source
            db_name         = "${var.db_name}${random_string.suffix.result}"
            admin_password  = var.db_admin_password
        }
    }
}

# Lookup OCI info base on Azure info
module "azure-oci-mapping" {
  source   = "../../modules/azure-oci-zone-mapping"
  location = var.az_region
  zone     = var.az_zone
}

# Oracle Database DB Home + CDB with default PDB
module "oci-database-db-home" {
    source = "../../modules/oci-database-db-home"
    depends_on       = [module.avm_exadata_vmc]
    database_db_home = local.database_db_home
}