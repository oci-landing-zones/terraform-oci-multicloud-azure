variable "vm_public_ip_address" {
  type = string
}

variable "ssh_private_key" {
  type = string
  sensitive   = true
}

variable "cdb_long_connection_string" {
  type        = string
}

variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "A strong password for SYS, SYSTEM, and PDB Admin. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -."
}

variable "pdb_long_connection_string" {
  type        = string
}