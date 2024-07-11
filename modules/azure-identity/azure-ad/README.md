# Azure AD Module 
## Introduction 
Automated step 2-5 in [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm).
Note: Limitation on step 4. Edit Attribute and Claims:
* Claim is created using claim mapping policy. This will not be visible in the UI, and the claim cannot be modified from the UI.
* Azure Ad module does not support the Group claim because the Azure Ad terraform provider does not support this function.
<sub>Note: Azure AD SAML app so that the user email address is used as the user name. You can change it by updating `samlNameIdFormat` for `nameidentifier`<sub>

## Providers

| Name | Version |
|------|---------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | ~> 2.48.0 |


## Modules
| Name                    |
|-------------------------|
| [azure-ad](../azure-ad) |

## Inputs Variables
| VARIABLE |                        DESCRIPTION                         | REQUIRED | DEFAULT_VALUE |                                              SAMPLE VALUE |
|:---------|:----------------------------------------------------------:|:--------:|--------------:|--------------------------------------------------------:|
|`oci_domain_uri`|                       OCI domain Url                       |   yes    |     odbaa_app | https://idcs-<unique_ID>.identity.oraclecloud.com:443/fed |
|`application_name`|                      application name                      |    No    |     odbaa_app |                                                         |
|`application_group_name`|                   application group name                   |    No    |            "" | "odbaa" |
|`user_email`| existing user email that will be added to the application. |    No    |            "" |  |
|`claim`| Enable this will edit Attributes and Claims in your new Azure AD SAML app so that the user email address is used as the user name. |    No    | true |  |
## Output Values
| VARIABLE |                        DESCRIPTION                         |                                                    SAMPLE VALUE                                                    |
|:---------|:----------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------:|
|`federation_metadata_xml`|  Azure SSO SAML application intgration url | https://login.microsoftonline.com/<unique_ID>/federationmetadata/2007-06/federationmetadata.xml?appid=<unique_ID>  |


### Authentication
```
# authenticate AZ cli
az login --tenant <azure-tenant-id>
```

## Execution
To create the odbaa_app OCI application with claim settings in step 4 for [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm).
```
$ terraform apply -var="oci_domain_uri=<your OCI Domain URL>"
```

To customize the application's name.
```
$ terraform apply -var="oci_domain_uri=<your OCI Domain URL>" -var="application_name=<your application name>"
```
To disable claim creation. 
```
$ terraform apply -var="oci_domain_uri=<your OCI Domain URL>" -var="claim=false"
```

To add a user and group to the application. 
```
$ terraform apply -var="oci_domain_uri=<your OCI Domain URL>" -var="application_group_name=<group name>" -var="user_email=<email>" 
```
