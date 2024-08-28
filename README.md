# OCI Multicloud Landing Zone for Azure

![Landing Zone logo](./images/landing_zone_300.png)

The [Oracle Cloud Infrastructure (OCI) Quick Start](https://github.com/oracle-quickstart?q=oci-quickstart) is a collection of examples that allow Oracle Cloud Infrastructure users to get a quick start deploying advanced infrastructure on OCI. This repository contains Terraform scripts specific to the [Oracle Database@Azure](https://www.oracle.com/cloud/azure/oracle-database-at-azure/) service.


This repository is under active development. Building open source software is a community effort. We're excited to engage with the community building this.

## Overview

A repository contains a collection of [terraform modules](https://developer.hashicorp.com/terraform/language/modules) and templates that helps an Azure administrator configure an Azure environment for Oracle Database@Azure and provision database related components (Exadata hardware, Virtual Machine (VM) Clusters, and databases) in Azure.

A user can apply the terraform plans from any computer that has connectivity to both Azure and OCI.

## Prerequisites

To use the Terraform modules and templates in your environment, you must install the following software on the system from which you execute the terraform plans:

- [Terraform](https://developer.hashicorp.com/terraform/install)
  - Alternate [OpenTofu](https://opentofu.org/docs/intro/)
- [Python 3.x](https://www.python.org/?downloads) (min version 3.4) with packages
  - [pip](https://pypi.org/project/pip/)
  - [venv](https://docs.python.org/3/library/venv.html) 
    - (venv) virtual env is recommended (not mandatory) to install python packages for [oci-identity-provider/scripts/requirements.txt](modules/oci-identity/oci-identity-provider/scripts/requirements.txt)
- Azure CLI - [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- OCI CLI - [Quickstart](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
    - Setup OCI-CLI to [authenticate to your tenancy](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.43.1/oci_cli_docs/cmdref/session/authenticate.html) 
    - Create a token auth profile in your oci config with `<MY_PROFILE_NAME>`

Dependent which cloud resources a module manages, it will use some subset of the terraform cloud providers:

- [OCI terraform provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
  - In this template example use OCI provider `SecurityToken` auth method, other acceptable provider implementation are described in [OCI terraform provider configuration doc](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm)
- [azuread terraform provider](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- [azurerm terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Provided Templates 

These module automates the provisioning of components for running Oracle Database@Azure. Each template can run independently and default input values are configured which can be overridden per customer's preferences.

- `templates/az-oci-sso-federation`: Configures Single Sign-on (SSO) Between OCI and Microsoft Azure with identity federation.
- `templates/az-oci-rbac-n-sso-fed`: Configures SSO Between OCI and Microsoft Azure with identity federation And role, groups required for Oracle Database@Azure.
- `templates/az-odb-rbac`: Creates Roles and Groups required for for Oracle Database@Azure.
- `templates/az-oci-exa-pdb`: Provisions Oracle database infrastructure including networks, Exadata Infrastructure, VM Cluster, and database.

*Please read the individual template documentation for more details*.

## Authentication

### OCI Authentication 

You must [authenticate to your oci tenancy](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.43.1/oci_cli_docs/cmdref/session/authenticate.html) with config auth profile as `<MY_PROFILE_NAME>`. All available OCI regions are defined in [Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#top).

``` shell
oci session authenticate --region=<MY_REGION_IDENTIFIER> --profile-name=<MY_PROFILE_NAME>
```

Example:

``` shell
oci session authenticate --region=us-ashburn-1 --profile-name=ONBOARDING
```

### AZ Authentication

Official Microsoft documentation to [authenticate to Azure using Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

``` shell
az login --tenant <azure-tenant-id>
```

## Execution 

Navigate into the `templates` directory.

**Note:** The Terraform state file writes to the directory from where you execute plans. You should keep this file in case you want to use Terraform to modify the environment configuration later. Refer to the Terraform documentation for more persistent and shareable ways to save state. 

### Setting up your environment with Terraform

Input variable can be set in the [Variable Definitions file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) (e.g. `terraform.tfvars`) or through the command line or environment variables:

``` terraform
config_file_profile="<MY_PROFILE_NAME>"
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
```

or via [Command Line](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line)

``` shell
terraform plan -var="config_file_profile=<MY_PROFILE_NAME>" -var="compartment_ocid=<MY_OCI_TENANCY_ID>" -var="region=<MY_REGION_IDENTIFIER>"
```

or via [Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name) 

``` shell
export TF_VAR_config_file_profile="<MY_PROFILE_NAME>"
export TF_VAR_compartment_ocid="<MY_OCI_TENANCY_ID>"
export TF_VAR_region="<MY_REGION_IDENTIFIER>"
```

### Initialization

When running for first time, initialize the workspace directory using:

Terraform: 

``` shell
terraform init
```

OpenTofu: 

``` shell
tofu init
```

### Application

To validate changes described without applying

Terraform: 

``` shell
terraform plan
```

OpenTofu:

``` shell
tofu plan
```

To apply changes and create resources

Terraform: 

``` shell
terraform apply
```

OpenTofu:

``` shell
tofu apply
```

### Destruction 

To remove all resources created in above steps, run destroy:

Terraform: 

``` shell
terraform destroy
```

OpenTofu:

``` shell
tofu destroy
```

## Further Documentation

### Terraform Provider
- [Oracle Cloud Infrastructure Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Azure Active Directory Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AzAPI Provider](https://registry.terraform.io/providers/Azure/azapi/latest/docs)

### Terraform Modules
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [OCI Landing Zones](https://github.com/oci-landing-zones/)

**Acknowledgement:** Code derived adapted from samples, examples and documentations provided by above mentioned providers.

## Help

Open an issue in this repository.

## Contributing

This project welcomes contributions from the community. Before submitting a pull request, please [review our contribution guide](./CONTRIBUTING.md).

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process.

## License

Copyright (c) 2024 Oracle and/or its affiliates.

Released under the Universal Permissive License v1.0 as shown at <https://oss.oracle.com/licenses/upl/>.