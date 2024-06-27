# Terraform Template to setup RBAC and SSO Federation between OCI & Azure

## Providers

| Name | Version |
|------|---------|
| [OCI](https://registry.terraform.io/providers/oracle/oci/latest/docs) | n/a |
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | ~> 2.48.0 |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | ~>3.0.0 |

## Module

| Name                                                                  |
|-----------------------------------------------------------------------|
| [oci-identity-domain](../../modules/oci-identity/oci-identity-domain) |
| [azure-rbac](../../modules/azure-identity)                                  |
| [azure-ad](../../modules/azure-identity/azure-ad)                           |
| [oci-identity-provider](../../modules/oci-identity/oci-identity-provider)   |

## Inputs Variables

Please refer to this [README.md](../az-oci-sso-federation/README.md).

### RBAC Input variables

| VARIABLE                 |                                                                                                              DESCRIPTION                                                                                                               | REQUIRED | DEFAULT_VALUE |                SAMPLE VALUE |
|:-------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------:|--------------:|----------------------------:|
| `rbac` | Set to \"all\" -- both EXA and ADB-S RBAC(Roles Based Access Control), \"exa\" -- only EXA RBAC(Roles Based Access Control), or \"adbs\" -- only ADB-S RBAC(Roles Based Access Control) to setup Azure RBAC for ODBAA, default is all. |    NO    |           all |  "all", "exa", "adbs" |
| `group_prefix` | Group name prefix in Azure  |   NO    |               |                 |


# Permissions
### OCI permissions 
1. Identity domain administrator role for the OCI IAM identity domain. See [Understanding Administrator Roles.](https://docs.oracle.com/en-us/iaas/Content/Identity/roles/understand-administrator-roles.htm#understand-administrator-roles)

### Azure Permissions
2. The Customer's Azure AD account with one of the following Azure AD roles is available :
    * Global Administrator OR
    * Cloud Application Administrator OR
    * Application Administrator 
#### RBAC role permissions
3. Role Based Access Control Administrator or User Access Administrator or role with below permissions at the minimum:
    ```
    "Microsoft.Authorization/roleDefinitions/read"
    "Microsoft.Authorization/roleDefinitions/write"
    "Microsoft.Authorization/roleDefinitions/delete"
    ```
    ```
    "Microsoft.Authorization/roleAssignments/read", 
    "Microsoft.Authorization/roleAssignments/write" 
    "Microsoft.Authorization/roleAssignments/delete"
    ```

**Please this read this [README.md](../az-oci-sso-federation/README.md) for instructions on how to run the module.**

## RBAC param

To only execute exa or adbs RBAC setup set `rbac` to `exa` or `adbs`

```
terraform apply ... -var="rbac=exa" # set to adbs for only ADB-S RBAC setup in Azure.
```

Append a prefix to all `odbaa-*` group names.
**Note**：If a prefix is appended to group names, then update the OCI policies in MulticloudLink_ODBAA_**DBAADbFamilyPolicy, MulticloudLink_ODBAA_Authorization_Policies, MulticloudLink_ODBAA__OCI_MCS_Policy, and any other policy that uses odbaa—group with the new group names on the OCI Side.
```
terraform apply ... -var="group_prefix=<put your prefix>"
```

Setting up RBAC for Exa and ADB-S in Azure customize group names

```
terraform apply ... -var="odbaa_exa_infra_administrator_group=<exa_infra group name>" -var="<more group var>=<your group name>"
```

