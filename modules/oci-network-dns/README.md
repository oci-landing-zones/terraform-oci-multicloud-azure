# oci-network-dns

## Summary

Terraform module for creating Private DNS Zone in a new Private DNS View at OCI

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_dns_view.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_view) | resource |
| [oci_dns_zone.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCID of OCI Compartment | `string` | n/a | yes |
| <a name="input_dns_view_name"></a> [dns\_view\_name](#input\_dns\_view\_name) | Name of DNS View | `string` | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Name of DNS Zone | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope of DNS View and DNS Zone. Default is PRIVATE | `string` | `"PRIVATE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags to be assigned for OCI resources | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_view"></a> [dns\_view](#output\_dns\_view) | n/a |
| <a name="output_dns_zone"></a> [dns\_zone](#output\_dns\_zone) | n/a |
<!-- END_TF_DOCS -->