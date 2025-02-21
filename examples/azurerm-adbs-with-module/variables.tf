# Avoid storing your admin password in Terraform configuration and follow TF best practices. 
# You can assign the value via environment variables or -var option in your pipeline.
# https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line 
# https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name

variable "admin_password" {
  description = "Admin password of ADB-S."
  type        = string
  sensitive   = true
  default     = "Your0wnDefaultPw"
}