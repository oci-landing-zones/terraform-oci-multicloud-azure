# Azure Identity  
## Introduction
Setup Roles Based access control for ODB@A service.

## Providers

| Name | Version |
|------|---------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | ~> 2.48.0 |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | ~>3.0.0 |


## Modules
| Name                       |
|----------------------------|
| [azure-rbac](./azure-rbac) |


## Inputs Variables
| VARIABLE |                   DESCRIPTION                    | REQUIRED |                                                  DEFAULT_VALUE |                                              SAMPLE VALUE |
|:---------|:------------------------------------------------:|:--------:|---------------------------------------------------------------:|--------------------------------------------------------:|
| `group_prefix` |         ODBAA Group Name Prefix in Azure         |    NO    | "" | |
|`adbs_rbac`| Setup RBAC for ADB-S in Azure. Default is false. |    NO    | false |  |
|`exa_rbac`|  Setup RBAC for Exa in Azure. Default is false.  |    NO    | false |  |

## Output Values
N/A

# Setup Roles based access
Setting up RBAC for Exa and ADB-S in Azure using default group names:
1. Create an ADBS admin role since we don’t have an Azure built-in role yet.
2. Create groups for adbs and exa.
3. Groups and roles assignment. See [azure-rabc](./azure-rbac/main.tf) for 2 and 3.

### Authentication
```
# authenticate AZ cli
az login --tenant <azure-tenant-id>
```

### Apply

```
$ terraform apply -var="adbs_rbac=true" -var="exa_rbac=true"
```
To only execute exa or adbs RBAC setup set `adbs_rbac` to `true` and `exa_rbac` to `false`
```
$ terraform apply -var="adbs_rbac=true" -var="exa_rbac=false" # exa_rbac set to true and adbs_rbac to false for only EXA RBAC setup in Azure.
```
Setting up RBAC for Exa and ADB-S in Azure customize group names
```
$ terraform apply -var="adbs_rbac=true" -var="exa_rbac=true" -var="odbaa_exa_infra_administrator_group=<put your exa_infra group name>" -var="<more group var>=<your group name>"
```