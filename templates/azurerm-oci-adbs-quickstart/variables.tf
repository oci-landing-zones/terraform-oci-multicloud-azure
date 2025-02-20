# Common

## Resource Tags
variable "common_tags" {
  description = "resource tags to be used in both Azure and OCI"
  type        = map(string)
  default = {
    createdby = "azurerm-oci-adbs-quickstart"
  }
}

## Mandatory to randomise namaing for resource group, exadata infra and vmcluster
variable "random_suffix_length" {
  type    = number
  default = 3
}

# Azure Verified Module (AVM)
variable "avm_enable_telemetry" {
  description = "This variable controls whether or not telemetry is enabled for the Azure Verified Modules"
  type        = bool
  default     = true
}

# Azure Resource Group (azure-resource-grp)
variable "az_region" {
  description = "The location of the resources on Azure. e.g. useast"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "Resource Group Name without rg suffix"
  default     = "oradb"
}

variable "new_rg" {
  type        = bool
  description = "Create new resource group or not"
  default     = true
}

# Azure VNet
variable "new_vnet" {
  type = bool
  description = "Create new VNet or not"
  default = "true"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-oci"
}

variable "virtual_network_address_space" {
  description = "The address space of the virtual network. e.g. 10.1.0.0/16"
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.virtual_network_address_space))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "delegated_subnet_name" {
  description = "The name of the delegated subnet"
  type        = string
  default     = "snet-delegate-oci"
}

variable "delegated_subnet_address_prefix" {
  description = "The address prefix of the delegated subnet for Oracle Database @ Azure within the virtual network. e.g. 10.1.1.0/24"
  type        = string
  default     = "10.1.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.delegated_subnet_address_prefix))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

# Autonomous Database.
variable "name" {
  description = "The name which should be used for this Autonomous Database."
  type        = string
  default     = "oraadbs"
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
  type        = list(string)
  default     = []
}

# OCI Authentication
variable "oci_config_file_profile" {
  type        = string
  description = "OCI Config file name"
  default     = null
}

variable "oci_tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
  default     = null
}
variable "oci_user_ocid" {
  type        = string
  description = "OCID of the OCI user"
  default     = null
}
variable "oci_private_key_path" {
  type        = string
  description = "The path (including filename) of the private key"
  default     = null
}
variable "oci_private_key_password" {
  type        = string
  description = "Passphrase used for the key, if it's encrypted"
  sensitive   = true
  default     = null
}

variable "oci_fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used"
  default     = null
}

# variable open_mode {
#   description = "Indicates the Autonomous Database mode. The database can be opened in READ_ONLY or READ_WRITE mode."
#   type = string
#   default = "READ_WRITE"
#   validation {
#     condition = contains(["READ_WRITE", "READ_ONLY"], var.open_mode)
#     error_message = "The value of open_mode must be either READ_ONLY or READ_WRITE."
#   }
# }

# variable "permission_level" {
#   description = "The Autonomous Database permission level. Restricted mode allows access only by admin users."
#   type = string
#   default = "UNRESTRICTED"
#   validation {
#     condition = contains(["UNRESTRICTED", "RESTRICTED"], var.permission_level)
#     error_message = "The value of open_mode must be either UNRESTRICTED or RESTRICTED."
#   }
# }

# variable "whitelisted_ips" {
#   description = "The client IP access control list (ACL). This is an array of CIDR notations and/or IP addresses. Values should be separate strings, separated by commas. Example: ['1.1.1.1','1.1.1.0/24','1.1.2.25']"
#   type = list(string)
#   default = []  
# }