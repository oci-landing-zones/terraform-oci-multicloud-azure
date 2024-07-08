# OCI Multicloud Landing Zone for Azure
![Landing Zone logo](./images/landing_zone_300.png)

The [Oracle Cloud Infrastructure (OCI) Quick Start](https://github.com/oracle-quickstart?q=oci-quickstart) is a collection of examples that allow Oracle Cloud Infrastructure users to get a quick start deploying advanced infrastructure on OCI.

The oci-quickstart-template repository contains the template that can be used for accelerating the construction of quickstarts that runs from local Terraform CLI, [OCI Resource Manager](https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) and [OCI Cloud Shell](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm).

This repo is under active development.  Building open source software is a community effort.  We're excited to engage with the community building this.

## Resource Manager Deployment
This Quick Start uses [OCI Resource Manager](https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) to make deployment easy, sign up for an [OCI account](https://cloud.oracle.com/en_US/tryit) if you don't have one, and just click the button below:

Note, if you use this template to create another repo you'll need to change the link for the button to point at your repo.

## Overview
A collection of [terraform modules](https://developer.hashicorp.com/terraform/language/modules)
and templates to create standard setups between Azure and OCI to onboard to ODB@A.

These are pre-release versions designed to be used as a starting point for customers to 
use or borrow examples from when managing their own cloud infrastructure according to their
security best practices.

A user can apply the terraform plans from any computer that has connectivity to both Azure and OCI.

## Prerequisites
The following software must be installed on the machine you run the terraform plans from.
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Python 3.x](https://www.python.org/?downloads) (min version 3.4) with packages
  - [pip](https://pypi.org/project/pip/)
  - [venv](https://docs.python.org/3/library/venv.html) 
    - (venv) virtual env is recommended (not mandatory) to install python packages for [oci-identity-provider/scripts/requirements.txt](modules/oci-identity/oci-identity-provider/scripts/requirements.txt)
- Azure CLI - [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- OCI CLI - [Quickstart](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
    - Setup OCI-CLI to [authenticate to your tenancy](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.43.1/oci_cli_docs/cmdref/session/authenticate.html) 
    - create a token auth profile in your oci config with `<MY_PROFILE_NAME>`

Dependent which cloud resources a module manages, it will use some subset of the terraform cloud providers:
- [OCI terraform provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
  - In this template example use OCI provider `SecurityToken` auth method, other acceptable provider implementation are described in  [OCI terraform provider configuration doc](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm)
- [azuread terraform provider](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- [azurerm terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)


## Provided Templates 
These module automates the provisioning of components for running Oracle.Database @ Azure. Each template can run independently and default input values are configured which can be overridden per customer's preferences.

- ```templates/az-oci-sso-federation```: Sets up SSO Between OCI and Microsoft Azure with identity federation
- ```templates/az-oci-rbac-n-sso-fed```: Sets up SSO Between OCI and Microsoft Azure with identity federation And role, groups required for Oracle.Database @ Azure
- ```templates/az-odb-rbac```: Sets up role, groups required for for Oracle.Database @ Azure.
- ```templates/az-oci-exa-pdb```: Sets up Oracle.database infrastructure including networks, Exadata Infrastructure, VM Cluster, and database

<sub>*Please read individual template documentation for more details</sub>


## Authentication
### OCI authentation 
Must [authenticate to your oci tenancy](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.43.1/oci_cli_docs/cmdref/session/authenticate.html)  with config auth profile as `<MY_PROFILE_NAME>`.  All available OCI regions are defined in [Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#top) 

```
oci session authenticate --region=<MY_REGION_IDENTIFIERr> --profile_name=<MY_PROFILE_NAME>

# e.g. oci session authenticate --region=us-ashburn-1 --profile_name=ONBOARDING
```

### AZ authentation
Official Microsoft documentation to [authenticate to Azure using Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
```
az login --tenant <azure-tenant-id>
```


## Execution 
Change directories into the template directory.
Note that the terraform state file will be written to the directory you run from. You should keep this file in case you want to use terraform to modify the setup. Read terraform documentation for more persistent and shareable ways to save your state. 

### Setting up your environment with Terraform
Input variable can be set either in  `terraform.tfvars` or command line e.g.
```
config_file_profile="<MY_PROFILE_NAME>"
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
```
or
```
terraform plan -var="config_file_profile=<MY_PROFILE_NAME>" -var="compartment_ocid=<MY_OCI_TENANCY_ID>" -var="region=<MY_REGION_IDENTIFIER>"
```

### Initialization
When running for first time, in workspace directory initialize 
```
terraform init
```

### Application
To validate changes described without applying
```
terraform plan
```

To apply changes and create resources
```
terraform apply
```

### Destruction 
To remove all resources created in above steps, run destroy
```
terraform destory
```

## Further Documentation

- [Terraform OCI Provider](https://www.terraform.io/docs/providers/oci/index.html)
- [Oracle Cloud Infrastructure Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Azure Active Directory Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)


## Acknowledgement

Code derived and adapted from [Terraform OKE Sample](https://github.com/terraform-providers/terraform-provider-oci/tree/master/examples/container_engine) and Hashicorp’s [Terraform 0.12 examples](https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/terraform-0.12-examples).


## Contributing

Learn how to [contribute](./CONTRIBUTING.md).

## License
Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates. Licensed under the [Universal Permissive License 1.0](./LICENSE) as shown at [https://oss.oracle.com/licenses/upl](https://oss.oracle.com/licenses/upl/).