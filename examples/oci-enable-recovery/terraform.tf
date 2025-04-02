terraform {
  required_providers {
    # https://registry.terraform.io/providers/oracle/oci/latest/docs
    oci = {
      source  = "oracle/oci"
      version = ">= 6.31.0"
    }
  }
}
