variable "location" {
  description = "The location of the exadata infrastructure."
  type        = string
}

variable "zones" {
  description = "The zone of the exadata infrastructure."
  type        = string
}

variable "resource_group" {
  type        = string
  description = "Resource Group Name"
}

variable "exadata_infrastructure_resource_name" {
  description = "The name of the exadata infrastructure on Azure."
  type        = string
}
# variable "exadata_infrastructure_resource_display_name" {
#   description = "The display name of the exadata infrastructure."
#   type        = string
# }

variable "exadata_infrastructure_compute_cpu_count" {
  description = "The number of compute servers for the cloud Exadata infrastructure."
  type        = number
}

variable "exadata_infrastructure_storage_count" {
  description = "The number of storage servers for the Exadata infrastructure."
  type        = number
}

variable "exadata_infrastructure_shape" {
  description = "The shape of the cloud Exadata infrastructure resource. e.g. Exadata.X9M"
  type        = string
}

variable "exadata_infrastructure_maintenance_window_lead_time_in_weeks" {
  description = "Lead time window allows user to set a lead time to prepare for a down time. The lead time is in weeks and valid value is between 1 to 4."
  type        = number
}

variable "exadata_infrastructure_maintenance_window_preference" {
  description = "The maintenance window scheduling preference.Allowed values are: NO_PREFERENCE, CUSTOM_PREFERENCE."
  type        = string
}

variable "exadata_infrastructure_maintenance_window_patching_mode" {
  description = "Cloud Exadata infrastructure node patching method, either ROLLING or NONROLLING."
  type        = string
}
