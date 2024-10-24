variable "database_db_home" {
  type = map(object({
    admin_password   = string
    defined_tags     = optional(map(string))
    freeform_tags    = optional(map(string))
    vm_cluster_id    = string
    db_home_version  = string
    db_home_name     = string
    db_home_source   = string
    db_name          = string
  }))
}