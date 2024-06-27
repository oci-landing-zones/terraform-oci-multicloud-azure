# config_file_*  are for tfm setup , refer https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm
variable "config_file_profile" {
  description = "The profile name if you would like to use a custom profile in the OCI config file to provide the authentication credentials. See Using the SDK and CLI Configuration File for more information, Refer: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#terraformproviderconfiguration_topic-SDK_and_CLI_Config_File"
  type        = string
}

variable "region" {
  description = "OCI region "
  type        = string
}

variable "compartment_ocid" {
  description = "for root compartment pass tenancy_ocid , else pass compartment_ocid"
  type        = string
}

variable "domain_display_name" {
  description = "Use default value unless using non default domain"
  type        = string
  default     = "Default"
}

variable "confidential_app_name" {
  type    = string
  default = "AzureEntra"
}
