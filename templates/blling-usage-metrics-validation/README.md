# blling-usage-metrics-validation

## Summary

Terraform module for verify Billing/Usage metrics are visible on OCI and Azure. 

## Providers

| Name                                                                        | Version |
|-----------------------------------------------------------------------------| ------- |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | ~>3.0.0 |

## Modules

| Name                                                                                                                        |
| --------------------------------------------------------------------------------------------------------------------------- |
| [billing-usage-metrics-validation](../../modules/billing-usage-metrics-validation) |

## Inputs Variables

| VARIABLE                    |                      DESCRIPTION                      | REQUIRED | DEFAULT_VALUE |                       SAMPLE VALUE |
|:----------------------------|:-----------------------------------------------------:|:--------:|--------------:|-----------------------------------:|
| `config_file_profile`       |                 OCI CLI profile name.                 |   Yes    |     "DEFAULT" |                       "ONBOARDING" |
| `compartment_ocid`          |           Tenancy OCID of root comparment.            |   Yes    |               | "ocid1.tenancy.oc1..xxxxxxxxxxxxx" |
| `azure_resource_name`       |          The resource name of the resource.           |   Yes    |               |                                    |
| `azure_resource_group_name` |       The resource group name of the resource.        |   Yes    |               |                                    |

## Output Values
N/A
## Execution

### Pre-requisite
1. To view Cost and Usage reports, you must have IAM policy in-place.
    Please refer to [costanalysis overview policy](https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/costanalysisoverview.htm#policy)
    It takes *8 hours* for billing and usage metrics to show up in OCI.
2. In order to view the billing and usages on Azure portal, you have to either have *Enterprise Admin* or *Enrollment reader* roles for the billing account.
    Please refer to [Assign access to Cost Management data](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/assign-access-acm-data)
    It takes *56 hours* for metrics to show up in Azure (48 hours on MSFT  + 8 hours in OCI).

### Authentication
1. Using `az login --use-device-code --tenant <AZURE_TENANT_ID>`.
2. Login to OCI tenancy by executing the following command: 
    ```
    # authenticate OCI cli
    oci session authenticate --region=<home-region>
    ```

### Application
#### Setting param value

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
Init
```
terraform init
```
Run

```
terraform apply
```
### Destruction

```
terraform destroy
rm -r ../../modules/billing-usage-metrics-validation/venv
```

### Known Issues:
NA
