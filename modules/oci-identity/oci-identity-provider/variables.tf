# config_file_*  are for tfm setup , refer https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm
variable "config_file_profile" {
  description = ""
  type        = string
  default     = "DEFAULT"
}

variable "region" {
  description = "OCI region "
  type        = string
}


variable "oci_domain_url" {
  description = "this will be output of module oci-identity-domain"
  type        = string
}


variable "az_federation_xml_url" {
  description = "this will be output of module oci-identity-domain"
  type        = string
}

variable "idp_name" {
  description = " name of identity provider, if not provided Default name will be used"
  type        = string
  default     = "AzureAD"
}


variable "idp_description" {
  description = "(optional) description of identity provider"
  type        = string
  default     = "" # empty 
}


variable "default_rule_id" {
  description = "name id of Default domain default IDP rule"
  type        = string
  default     = "DefaultIDPRule"
}
