# Identity Lifecycle Management Between OCI IAM and Azure AD

Configure Azure AD as the authoritative identity store to manage identities in OCI IAM using an application template from the Azure AD gallery. User accounts are pushed from Azure AD to OCI IAM.
Official steps documentation available at : [https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/lifecycle_azure/01-config-azure-template.htm#config-azure-template]

## Introduction

Configure Azure AD as the authoritative identity store to manage identities in OCI IAM using the app template from OCI IAM Application Catalog. OCI IAM pulls users, groups, and group membership from Azure AD into OCI IAM.

## Providers

| Name                                                                        | Version   |
| --------------------------------------------------------------------------- | --------- |
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | ~> 2.48.0 |

## Modules

| Name                    |
| ----------------------- |
| [azure-id-lifecycle](.) |

## Inputs Variables

| VARIABLE                            |                                                        DESCRIPTION                                                        | REQUIRED | DEFAULT_VALUE |                                                   SAMPLE VALUE |
| :---------------------------------- | :-----------------------------------------------------------------------------------------------------------------------: | :------: | ------------: | -------------------------------------------------------------: |
| `az_ad_app_object_id`      |                                     ObjectId of azure enterprise app created for sso                                      |   YES    |               |                                                    <unique_id> |
| `oci_confidential_app_secret_token` |                              base64Encode of OCI confidential app's client-id:client-secret                               |   YES    |               |                                                    <unique_id> |
| `oci_domain_identity_admin_url`     |                                                   OCI domain admin url                                                    |   YES    |               | https://idcs-<unique-id>.identity.oraclecloud.com:443/admin/v1 |


## Output Values

| VARIABLE                   |                  DESCRIPTION                  | SAMPLE VALUE |
| :------------------------- | :-------------------------------------------: | :----------: |
| `sso_service_principal_id` |  Azure SSO application service principal id   | <unique_id>  |
| `provision_job_id`         | Indentity provisioning synchronization job id | <unique_id>  |

# Azure AD as Authoritative Source to Manage Identities Using Azure AD Gallery Application

1. Create an app in Azure AD and use the secret token and identity domain URL to specify the OCI IAM identity domain, and prove that it works by pushing users from Azure AD to OCI IAM.

2. Additional identity provisioning user mapping attributes setup for
   - Set users' federated status so that they're authenticated by the external identity provider.
   - Stop users getting notification emails when their account is created or updated.

### Authentication

```
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
1. It has been observed  user provisioning failure due to missing first name, last name or email of user. To mitigate, update user properties to add missing information.
