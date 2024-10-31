terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_database_db_home" "this" {
    for_each = var.database_db_home
    vm_cluster_id      = each.value.vm_cluster_id
    display_name       = each.value.db_home_name
    db_version         = each.value.db_home_version
    source             = each.value.db_home_source
    defined_tags       = each.value.defined_tags
    freeform_tags      = each.value.freeform_tags
    database {
        admin_password = each.value.admin_password
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags
        db_name        = each.value.db_name
    }
    lifecycle {
      ignore_changes = all
    }
}
