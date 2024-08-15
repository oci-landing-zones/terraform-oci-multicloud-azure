variable "vm_public_ip_address" {
  type        = string
  description = "The public IP address of the Virtual machine."
}

variable "ssh_private_key" {
  type        = string
  sensitive   = true
  description = "The ssh private key use to connect to VM."
}

variable "cdb_long_connection_string" {
  type        = string
  description = "The long connection string of the CDB ."
}

variable "pdb_long_connection_string" {
  type        = string
  description = "The long connection string of the PDB."
}

variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "The Database Administrator password."
}
