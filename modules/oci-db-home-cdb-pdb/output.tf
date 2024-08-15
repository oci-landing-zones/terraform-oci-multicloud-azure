output "cdb_connection_string" {
  value = oci_database_database.exa_cdb.connection_strings[0].cdb_ip_default
}

output "pdb_connection_string" {
  value = oci_database_pluggable_database.exa_pdb.connection_strings[0].pdb_ip_default
}
