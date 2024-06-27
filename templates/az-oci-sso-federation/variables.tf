# Required 
variable "config_file_profile" {
  description = "The profile name if you would like to use a custom profile in the OCI config file to provide the authentication credentials. See Using the SDK and CLI Configuration File for more information, Refer: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#terraformproviderconfiguration_topic-SDK_and_CLI_Config_File"
  type        = string
  # default = "DEFAULT"
}

variable "compartment_ocid" {
  description = "OCID of your tenancy. To get the value, see Where to Get the Tenancy's OCID and User's OCID, Refer: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five"
  type        = string
}

variable "region" {
  description = "Region Identifier for OCI region. See Regions and Availability Domains, Refer: https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm"
  type        = string
}

# Optional
variable "domain_display_name" {
  description = "OCI Identify Domain Name"
  type        = string
  default     = "Default"
}
variable "confidential_app_name" {
  type    = string
  default = "AzureEntra"
}
variable "az_application_name" {
  description = "The display name for the Azure Entra ID Application."
  type        = string
  default     = "ORACLE IAM"
}

variable "idp_name" {
  description = "The display name for the Identity provider."
  type        = string
  default     = "AzureAD"
}

variable "idp_description" {
  description = "Description of identity provider"
  type        = string
  default     = "" # empty 
}

variable "default_rule_id" {
  description = "Name-id of Default domain default IDP rule"
  type        = string
  default     = "DefaultIDPRule"
}

variable "application_group_name" {
  type        = string
  default     = ""
  description = "User application group name that will be added to the application"
}

variable "user_email" {
  type        = string
  default     = ""
  description = "Existing user email that will be added to the application."
}
