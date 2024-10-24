output "database_db_home" {
  description = "Database DB HOME informations."
  value       = length(oci_database_db_home.this) > 0 ? oci_database_db_home.this[*] : null
}

output "db_home_id" {
  description = "OCID of DB Home"
  value       = [ for b in oci_database_db_home.this : b.id]
}

output "db_system_id" {
  description = "OCID of DB System"
  value = join(", ", [for b in oci_database_db_home.this : b.id])
}
