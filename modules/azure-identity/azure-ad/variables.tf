variable "oci_domain_uri" {
  type        = string
  description = "A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant. I,e https://idcs-<unique_ID>.identity.oraclecloud.com:443/fed"
}

## Optional input variables.

variable "application_name" {
  type        = string
  default     = "odbaa_app"
  description = "The display name for the application."
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

variable "claim" {
  type        = bool
  default     = true
  description = "Enable this will edit Attributes and Claims in your new Azure AD SAML app so that the user email address is used as the user name."
}
