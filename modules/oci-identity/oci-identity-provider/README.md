# Terraform Template to setup SSO Federation between OCI & Azure 
Terraform module to create SAML identity provider (IdP) and configure it in Default IdP policy rule. This is described instep 6 of [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm) 

## Providers

| Name | Version |
|------|---------|
| [OCI](https://registry.terraform.io/providers/oracle/oci/latest/docs) | n/a |


## Modules
| Name |
|------|
|[oci-identity-provider](modules/oci-identity/oci-identity-provider)|





## Inputs Variables 

| VARIABLE | DESCRIPTION | REQUIRED |  DEFAULT_VALUE | SAMPLE VALUE |
|:---------|:--------:|:--------:|------:|------:|
|`config_file_profile`| OCI CLI profile name| Yes |  | "ONBOARDING" |
|`region`| OCI region | Yes | | 'us-ashburn-1' |
|`oci_domain_url`| |  OCI doamin url  |  |  https://idcs-<unique_ID>.identity.oraclecloud.com:443 |
|`az_federation_xml_url`| Azure SSO SAML application intgration url   |   |    |  https://login.microsoftonline.com/<unique_ID>/federationmetadata/2007-06/federationmetadata.xml?appid=<unique_ID> |
|`idp_name` | Display name for the Identity provider | No | "AzureAD" |   |
|`idp_description`| Description of identity provider | No | "" |   |
|`default_rule_id`| Name-id of Default domain default IDP rule | No |  "DefaultIDPRule" |   |


## Output Values
| VARIABLE | DESCRIPTION | SAMPLE VALUE |
|:---------|:--------:|:--------:|
<!--| saml_idp_id | Newly created SAML Idp Id| 131dbf70c9074efdb13a3f625277316f | -->




### Setting param value 
The following input tfvars *must* be set

Either as `terraform.tfvars` file in same directory
```
config_file_profile="<MY_PROFILE_NAME>"
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
```

Or running as command line parameter
```
terraform apply -var="config_file_profile=ONBOARDING"  -var='...
```

### Authentication
```
# authenticate OCI cli
oci session authenticate --region=<region-identifier>

# authenticate AZ cli
az login --tenant <azure-tenant-id>
```
 


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
