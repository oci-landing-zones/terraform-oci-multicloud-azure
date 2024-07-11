# Terraform Template to setup SSO Federation between OCI & Azure 
Terraform Template to step up [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm) This template peforms all steps described in document using Terraform.


## Providers

| Name | Version |
|------|---------|
| [OCI](https://registry.terraform.io/providers/oracle/oci/latest/docs) | n/a |
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | n/a |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | n/a |


## Modules
| Name                                                                  |
|-----------------------------------------------------------------------|
| [oci-identity-domain](../../modules/oci-identity/oci-identity-domain) |
| [azure-ad](../../modules/azure-identity/azure-ad)                           |
| [oci-identity-provider](../../modules/oci-identity/oci-identity-provider)   |


# Permissions
### OCI permissions 
Identity domain administrator role for the OCI IAM identity domain. See [Understanding Administrator Roles.](https://docs.oracle.com/en-us/iaas/Content/Identity/roles/understand-administrator-roles.htm#understand-administrator-roles)

### Azure Permissions
The Customer's Azure AD account with one of the following Azure AD roles is available :
    * Global Administrator OR
    * Cloud Application Administrator OR
    * Application Administrator 


## Inputs Variables 

| VARIABLE | DESCRIPTION | REQUIRED |  DEFAULT_VALUE | SAMPLE VALUE |
|:---------|:--------:|:--------:|------:|------:|
|`config_file_profile`| OCI CLI profile name| Yes |  | "ONBOARDING" |
|`compartment_ocid` | Tenancy OCID of root comparment, unless default domain is in different compartment   | Yes |  | "ocid1.tenancy.oc1..xxxxxxxxxxxxx" |
|`region` |OCI region Identifier | Yes |  | "us-ashburn-1" |
|`domain_display_name`| OCI Identify Domain Name | No | "Default" |   |
|`az_application_name`| Display name for the Azure Entra ID Application | No |  "ORACLE IAM" |   |
|`idp_name` | Display name for the Identity provider | No | "AzureAD" |   |
|`idp_description`| Description of identity provider | No | "" |   |
|`default_rule_id`| Name-id of Default domain default IDP rule | No |  "DefaultIDPRule" |   |
|`application_group_name`|  group name that will be added to the application  |    No    |            "" | "odbaa" |
|`user_email`| existing user email that will be added to the application |    No    |            "" |  |
|`confidential_app_name`| OCI confidential application of identity federation |    No    |  "AzureEntra" |    |


### Setting param value 
The following input tfvars *must* be set

Either as `terraform.tfvars` file in same directory
```
config_file_profile="<MY_PROFILE_NAME>"
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
...
```

Or running as command line parameter
```
terraform apply -var="config_file_profile=ONBOARDING"  -var='compartment_ocid=ocid1.tenancy.oc1..xxxxxxxxxxxxx' -var='region=us-ashburn-1'  ...
```

### Authentication
```
# authenticate OCI cli
oci session authenticate --region=<region-identifier>

# authenticate AZ cli
az login --tenant <azure-tenant-id>
```
 
### Set Azure MS graph api token as env variable 
**Required to run identity lifecycle:** Additional identity provisioning user mapping attributes setup needs ms-graph access token 
```
# Set env AZ_TOKEN
export AZ_TOKEN=$(az account get-access-token --resource-type ms-graph | jq -r .accessToken)


# If you dont have 'jq', either install it or run below, and set  `accessToken` as  AZ_TOKEN env var
az account get-access-token --resource-type ms-graph 
export AZ_TOKEN=<access_token_value>
```
**doc:**[get-azaccesstoken](https://learn.microsoft.com/en-us/powershell/module/az.accounts/get-azaccesstoken) 


## Troubleshooting
### Known Issues:
#### 5XX error from Identity Domains Setting

```
Error: 500-BadErrorResponse,
Suggestion: The service for this resource encountered an error. Please contact support for help with service: Identity Domains Setting
Documentation: https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_domains_setting
API Reference: https://docs.oracle.com/iaas/api/#/en/identity-domains/v1/Setting/PutSetting
Request Target: PUT https://idcs-<>/admin/v1/Settings/Settings?attributeSets=all
Provider version: 5.46.0, released on 2024-06-12.
Service: Identity Domains Setting
Operation Name: PutSetting
OPC request ID: xxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxx
```
**Workaround:** 
1. Remove created resources: ```terraform destory```
2. Retry / re-apply: ```terraform apply```
