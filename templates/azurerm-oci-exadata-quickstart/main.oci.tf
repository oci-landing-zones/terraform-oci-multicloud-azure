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
  oci_region = module.azurerm_exadata_infra.oci_region
  oci_compartment_ocid = module.azurerm_exadata_infra.oci_compartment_ocid
  oci_vcn_ocid = module.azurerm_exadata_vmc.oci_vcn_ocid
  oci_nsg_ocid = module.azurerm_exadata_vmc.oci_nsg_ocid
  oci_zone_id  = var.vm_cluster_domain!= "" ? data.oci_dns_zones.this[0].zones[0].id : ""

  # Assign OCI tags  
  oci_tags = var.common_tags

  # Oracle Database DB Home + Container Database (CDB) with default Pluggable Database (PDB)
  database_db_home = {
        db_home_1 = {
            vm_cluster_id   = module.azurerm_exadata_vmc.vm_cluster_ocid
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

# Get OCID of oci_dns_zones
data "oci_dns_zones" "this" {
    count = var.vm_cluster_domain!= "" ? 1 : 0
    compartment_id = local.oci_compartment_ocid
    name = var.vm_cluster_domain
    scope = "PRIVATE"
    zone_type = "PRIMARY"
    depends_on = [ module.oci-network-dns ]
}

# Create Private DNS Zone in a new DNS view if custome domain is configured
module "oci-network-dns" {
  count = (var.vm_cluster_new_oci_dns && var.vm_cluster_domain!= "") ? 1 : 0
  source = "../../modules/oci-network-dns"
  compartment_id = local.oci_compartment_ocid
  dns_view_name = "${local.vm_cluster_name}"
  dns_zone_name = var.vm_cluster_domain
  scope = "PRIVATE"
  tags = local.az_tags
  # depends_on = [ module.azurerm_exadata_infra, module.azure-resource-grp ]
}

# Oracle Database DB Home + CDB with default PDB
module "oci-database-db-home" {
    count = startswith(lower(var.exadata_infrastructure_name),"ofake_")? 0:1
    source = "../../modules/oci-database-db-home"
    depends_on       = [module.azurerm_exadata_vmc]
    database_db_home = local.database_db_home
}

# Get Container DB info for output
data "oci_database_databases" "cdb" {
    compartment_id = local.oci_compartment_ocid
    db_home_id = module.oci-database-db-home[0].db_home_id[0]
}

# Get Pluggable DB info for output
data "oci_database_pluggable_databases" "pdb" {
    compartment_id = local.oci_compartment_ocid
    database_id = data.oci_database_databases.cdb.system_id
}