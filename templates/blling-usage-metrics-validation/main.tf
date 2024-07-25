module "billing_usage_metrics_validation" {
  source = "../../modules/billing-usage-metrics-validation"
  providers = {
    azurerm = azurerm
  }
  config_file_profile = var.config_file_profile
  azure_resource_group_name = var.azure_resource_group_name
  azure_resource_name       = var.azure_resource_name
  oci_compartment_ocid      = var.oci_compartment_ocid
}