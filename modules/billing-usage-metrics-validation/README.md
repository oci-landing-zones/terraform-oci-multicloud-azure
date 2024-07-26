# billing-usage-metrics-validation

## Summary

Terraform module for verify Billing/Usage metrics are visible on OCI and Azure. 

## Providers

| Name                                                                        | Version |
|-----------------------------------------------------------------------------| ------- |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | ~>3.0.0 |

## Inputs Variables

| VARIABLE                    |                      DESCRIPTION                      | REQUIRED | DEFAULT_VALUE |                       SAMPLE VALUE |
|:----------------------------|:-----------------------------------------------------:|:--------:|--------------:|-----------------------------------:|
| `config_file_profile`       |                 OCI CLI profile name.                 |   Yes    |     "DEFAULT" |                       "ONBOARDING" |
| `compartment_ocid`          |           Tenancy OCID of root comparment.            |   Yes    |               | "ocid1.tenancy.oc1..xxxxxxxxxxxxx" |
| `azure_resource_name`       |          The resource name of the resource.           |   Yes    |               |                                    |
| `azure_resource_group_name` |       The resource group name of the resource.        |   Yes    |               |                                    |

## Output Values

## Execution
### Authentication
1. Using `az login --use-device-code --tenant <AZURE_TENANT_ID>`.
2. Using `az account set <AZURE_SUBSCRIPTION_ID>` to specify the desired subscription ID if you have multiple subscriptions within a tenant.
3. Login to OCI tenancy by executing the following command: 
    ```
    # authenticate OCI cli
    oci session authenticate --region=<region-identifier>
   
### Setting param value

The following input tfvars _must_ be set

Either as `terraform.tfvars` file in same directory

```
config_file_profile="<MY_OCI_PROFILE_NAME>"
oci_compartment_ocid="<MY_OCI_TENANCY_ID>"
azure_resource_group_name = "<MY_AZURE_RESOURCE_GROUP>"
azure_resource_name       = "<MY_AZURE_RESOURCE_NAME>"
```

Or running as command line parameter

```
terraform apply -var="config_file_profile=DEFAULT"  -var='compartment_ocid=ocid1.tenancy.oc1..xxxxxxxxxxxxx' -var='azure_resource_group_name=xxx' -var='azure_resource_name=xxx'
```

Init and Run
```
terraform init
terraform run
```

### Destruction

```
terraform destroy
rm -r ../../modules/billing-usage-metrics-validation/venv
```

## Troubleshooting

### Known Issues:
NA
