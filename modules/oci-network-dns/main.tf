terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
resource "oci_dns_view" "this" {
    compartment_id = var.compartment_id
    scope = var.scope
    display_name = var.dns_view_name
    freeform_tags = var.tags
}

resource "oci_dns_zone" "this" {
    compartment_id = var.compartment_id
    name = var.dns_zone_name
    zone_type = "PRIMARY"
    view_id = oci_dns_view.this.id
    scope = var.scope
    freeform_tags = var.tags
}
