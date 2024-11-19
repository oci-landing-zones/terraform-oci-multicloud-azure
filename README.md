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
- Azure CLI - [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- OCI CLI - [Quickstart](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
    - Setup OCI-CLI to [authenticate to your tenancy](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.43.1/oci_cli_docs/cmdref/session/authenticate.html) 
    - Create a token auth profile in your oci config with `<MY_PROFILE_NAME>`
requirements.txt)
- [Python 3.x](https://www.python.org/?downloads) (min version 3.4) with packages
  - [pip](https://pypi.org/project/pip/)
  - [venv](https://docs.python.org/3/library/venv.html) 
    - (venv) virtual env is recommended (not mandatory) to install python packages for [oci-identity-provider/scripts/requirements.txt](modules/oci-identity/oci-identity-provider/scripts/

Dependent which cloud resources a module manages, it will use some subset of the terraform cloud providers:

- [OCI terraform provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
  - In this template example use OCI provider `SecurityToken` auth method, other acceptable provider implementation are described in [OCI terraform provider configuration doc](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm)
- [azuread terraform provider](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- [azurerm terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Provided Templates 

These module automates the provisioning of components for running Oracle Database@Azure. Each template can run independently and default input values are configured which can be overridden per customer's preferences.

### Exadata
- `templates/azurerm-oci-exadata-quickstart`: Quickstart OracleDB@Azure (Exadata) with OCI LZ modules (AzureRM)
- `templates/avm-oci-exadata-quickstart`: Quickstart OracleDB@Azure (Exadata) with Azure Verified Modules (AzAPI) and OCI LZ Modules

### Autonomous Database
- `templates/azurerm-oci-adbs-quickstart`: Quickstart OracleDB@Azure (Autonomous Database) with OCI LZ modules (AzureRM)

### Identity
- `templates/az-oci-sso-federation`: Configures Single Sign-on (SSO) Between OCI and Microsoft Azure with identity federation.
- `templates/az-oci-rbac-n-sso-fed`: Configures SSO Between OCI and Microsoft Azure with identity federation And role, groups required for Oracle Database@Azure.
- `templates/az-odb-rbac`: Creates Roles and Groups required for for Oracle Database@Azure.
- `templates/az-oci-exa-pdb`: Provisions Oracle database infrastructure including networks, Exadata Infrastructure, VM Cluster, and database.

*Please read the individual template documentation for more details*.

## Authentication

### OCI Authentication 
The OCI Terraform provider supports [multiple authentication methods](https://docs.oracle.com/en-us/iaas/Content/terraform/configuring.htm). We recommend to configure OCI Terraform Provider using API Key Authentication as illustrated below. Please refer to the [documentation](https://docs.oracle.com/en-us/iaas/Content/terraform/configuring.htm#api-key-auth) for details.

``` shell
export TF_VAR_oci_tenancy_ocid="OCID of the OCI tenancy"
export TF_VAR_oci_user_ocid="<OCID of the OCI user>"
export TF_VAR_oci_private_key_path="<path (including filename) of the private key>"
export TF_VAR_oci_fingerprint="<Key's fingerprint>"
```

You can verify the configuration using OCI CLI as illustrated below.
``` shell
export OCI_CLI_TENANCY=$TF_VAR_oci_tenancy_ocid
export OCI_CLI_USER=$TF_VAR_oci_user_ocid
export OCI_CLI_FINGERPRINT=$TF_VAR_oci_fingerprint
export OCI_CLI_KEY_FILE=$TF_VAR_oci_private_key_path
oci iam tenancy get --tenancy-id $TF_VAR_oci_tenancy_ocid --output table --query "data.{Name:name, OCID:id}" --auth api_key
```

### AZ Authentication
You can authenticate to Azure with [service principal](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash) and verify it with Azure CLI as illustrated below. Please refer to the offical [Azure documentation](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#2-authenticate-terraform-to-azure) for details.


``` shell
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
az account show -o table
```

## Execution 
Navigate into the `templates` directory.

**Note:** The Terraform state file writes to the directory from where you execute plans. You should keep this file in case you want to use Terraform to modify the environment configuration later. Refer to the Terraform documentation for more persistent and shareable ways to save state. 

### Setting up your environment with Terraform

Input variable can be set in the [Variable Definitions file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) (e.g. `terraform.tfvars`) or through the command line or environment variables:

``` terraform
compartment_ocid="<MY_OCI_TENANCY_ID>"
region="<MY_REGION_IDENTIFIER>"
```

or via [Command Line](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line)

``` shell
terraform plan -var="compartment_ocid=<MY_OCI_TENANCY_ID>" -var="region=<MY_REGION_IDENTIFIER>"
```

or via [Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name) 

``` shell
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
- [AzureRm Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
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