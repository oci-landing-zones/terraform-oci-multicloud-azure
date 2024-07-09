# Terraform Template to setup SSO Federation between OCI & Azure

Terraform module to fetch service provider metadata url and enable global access i.e. without authorization. This module performs step 1 of [SSO Between OCI and Microsoft Azure](https://docs.oracle.com/en-us/iaas/Content/Identity/tutorials/azure_ad/sso_azure/azure_sso.htm)

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| [OCI](https://registry.terraform.io/providers/oracle/oci/latest/docs) | n/a     |

## Modules

| Name                                                            |
| --------------------------------------------------------------- |
| [oci-identity-domain](modules/oci-identity/oci-identity-domain) |

## Inputs Variables

| VARIABLE                |                     DESCRIPTION                     | REQUIRED | DEFAULT_VALUE |                       SAMPLE VALUE |
| :---------------------- | :-------------------------------------------------: | :------: | ------------: | ---------------------------------: |
| `config_file_profile`   |                OCI CLI profile name                 |   Yes    |               |                       "ONBOARDING" |
| `compartment_ocid`      |  Tenancy OCID of root comparment, unless default domain is in different compartment |   Yes    |               | "ocid1.tenancy.oc1..xxxxxxxxxxxxx" |
| `region`                |                OCI region Identifier                |   Yes    |               |                     "us-ashburn-1" |
| `domain_display_name`   |              OCI Identify Domain Name               |    No    |     "Default" |                                    |
| `confidential_app_name` | OCI confidential application of identity federation |    No    |  "AzureEntra" |                                    |

## Output Values

| VARIABLE | DESCRIPTION |                             SAMPLE VALUE                              |
| :---------------------- | :-------------------------------------------------: | :------: | 
| `domain_url`                         |                    Identity domains url                    |          https://idcs-xxxxxxxxx.identity.pint.oracle.com:443          |
| `domain_metadata_xml_url`             |             Identity domains metadata xml url              | https://idcs-xxxxxxxxx.identity.pint.oc9qadev.com:443/fed/v1/metadata |
| `oci_confidential_app_secret_token` | base64Encode of confidential app's client-id:client-secret |                              <unique_id>                              |
| `oci_domain_identity_admin_url`     |                    Identity domain admin url                   | https://idcs-<unique-id>.identity.oraclecloud.com:443/admin/v1 |

### Setting param value

The following input tfvars _must_ be set

Either as `terraform.tfvars` file in same directory

```
config_file_profile="<MY_PROFILE_NAME>"
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
```

Or running as command line parameter

```
terraform apply -var="config_file_profile=ONBOARDING"  -var='compartment_ocid=ocid1.tenancy.oc1..xxxxxxxxxxxxx' -var='region=us-ashburn-1'
```

### Authentication

```
# authenticate OCI cli
oci session authenticate --region=<region-identifier>
```

## Troubleshooting

### Known Issues:
NA
