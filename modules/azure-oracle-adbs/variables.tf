variable "location" {
  type        = string
  description = "Resource region"
}

# Network Vars
variable "nw_resource_group" {
  type        = string
  description = "Virtual network resource group name"
}

variable "nw_vnet_name" {
  type        = string
  description = "Virtual network name"
}

variable "nw_delegated_subnet_name" {
  type        = string
  description = "Oracle delegate subnet name"
}

## ADB-S variables
#**NOTE:** Please refer to autonomous database official documentation. 
variable "db_resource_group" {
  type = string
  description = "Autonomous Database resource group name"
}

variable "name" {
  description = "The name which should be used for this Autonomous Database."
  type        = string
}

variable "display_name" {
  description = "The user-friendly name for the Autonomous Database. The name does not have to be unique."
  type        = string
  default     = ""
}

variable "db_workload" {
  description = "The Autonomous Database workload type. The following values are valid: OLTP, DW, AJD, APEX"
  type        = string
  default     = "DW"
}

variable "mtls_connection_required" {
  description = "Specifies if the Autonomous Database requires mTLS connections."
  type        = bool
  default     = false
}
variable "backup_retention_period_in_days" {
  description = "Retention period, in days, for backups."
  type        = number
  default     = 60
}

variable "compute_model" {
  description = "The compute model of the Autonomous Database. This is required if using the computeCount parameter. If using cpuCoreCount then it is an error to specify computeModel to a non-null value. ECPU compute model is the recommended model and OCPU compute model is legacy."
  type        = string
  default     = "ECPU"
}

variable "data_storage_size_in_tbs" {
  description = "The maximum storage that can be allocated for the database, in terabytes."
  type        = number
  default     = 1
}

variable "auto_scaling_for_storage_enabled" {
  description = "Indicates if auto scaling is enabled for the Autonomous Database storage. The default value is false."
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "The password must be between 12 and 30characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol or the username 'admin', regardless of casing."
  type        = string
  sensitive   = true
}

variable "auto_scaling_enabled" {
  description = " Indicates if auto scaling is enabled for the Autonomous Database CPU core count. The default value is true."
  type        = bool
  default     = true
}

variable "character_set" {
  description = "The character set for the autonomous database. The default is AL32UTF8"
  type        = string
  default     = "AL32UTF8"
}

variable "compute_count" {
  description = "The compute amount (CPUs) available to the database. Minimum and maximum values depend on the compute model and whether the database is an Autonomous Database Serverless instance or an Autonomous Database on Dedicated Exadata Infrastructure. For an Autonomous Database Serverless instance, the ECPU compute model requires a minimum value of one, for databases in the elastic resource pool and minimum value of two, otherwise. Required when using the computeModel parameter. When using cpuCoreCount parameter, it is an error to specify computeCount to a non-null value. Providing computeModel and computeCount is the preferred method for both OCPU and ECPU."
  type        = number
  default     = 2
}

variable "national_character_set" {
  description = "The national character set for the autonomous database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8."
  type        = string
  default     = "AL16UTF16"
}

variable "license_model" {
  description = "The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Oracle Database service."
  type        = string
  default     = "BringYourOwnLicense"
  validation {
    condition     = contains(["LicenseIncluded", "BringYourOwnLicense"], var.license_model)
    error_message = "The value of open_mode must be either BringYourOwnLicense or LicenseIncluded."
  }
}

variable "db_version" {
  description = "A valid Oracle Database version for Autonomous Database."
  type        = string
  default     = "23ai"
}

variable "customer_contacts" {
  description = "The email address used by Oracle to send notifications regarding databases and infrastructure. Provide up to 10 unique maintenance contact email addresses."
  type        = list(object({
    email = string
  }))
  default     = []
}

variable open_mode {
  description = "Indicates the Autonomous Database mode. The database can be opened in READ_ONLY or READ_WRITE mode."
  type = string
  default = "ReadWrite"
  validation {
    condition = contains(["ReadWrite", "ReadOnly"], var.open_mode)
    error_message = "The value of open_mode must be either ReadOnly or ReadWrite."
  }
}

variable "permission_level" {
  description = "The Autonomous Database permission level. Restricted mode allows access only by admin users."
  type = string
  default = "Unrestricted"
  validation {
    condition = contains(["Unrestricted", "Restricted"], var.permission_level)
    error_message = "The value of open_mode must be either Unrestricted or Restricted."
  }
}

variable "whitelisted_ips" {
  description = "The client IP access control list (ACL). This is an array of CIDR notations and/or IP addresses. Values should be separate strings, separated by commas. Example: ['1.1.1.1','1.1.1.0/24','1.1.2.25']"
  type = list(string)
  default = []  
}

variable "tags" {
  description = "Tags of the resource."
  type        = map(string)
  default = {
    "TF-MOD" = "azure-oracle-adbs"
  }
}

# variable "cpu_core_count" {
#   description = "The number of CPU cores to be made available to the database."
#   type = number
#   default = 2
# }

# variable "local_disaster_recovery_type" {
#   type = string
#   default = "BackupBased"
#   validation {
#     condition = contains(["BackupBased", "Adg"], var.permission_level)
#     error_message = "The value of local_disaster_recovery_type must be either BackupBased or Adg."
#   }
# }

variable "local_dataguard_enabled" {
  description = "Indicates whether the Autonomous Database has local or called in-region Data Guard enabled."
  type = bool
  default = false
}

variable "local_adg_auto_failover_max_data_loss_limit" {
  description = "Parameter that allows users to select an acceptable maximum data loss limit in seconds, up to which Automatic Failover will be triggered when necessary for a Local Autonomous Data Guard"
  type = number
  default = 0
}
