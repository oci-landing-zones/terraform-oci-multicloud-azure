# exadata-limits
Terraform Template to get info for exadata limits raising.

## Providers

| Name | Version |
|------|---------|
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | n/a |


## Modules
| Name                                                                  |
|-----------------------------------------------------------------------|
| [azure-region-zone](../../modules/azure-oci-zone-mapping) |


## Inputs Variables 

| VARIABLE                                   |                                                                                                                                                                   DESCRIPTION                                                                                                                                                                    | Type | REQUIRED | DEFAULT_VALUE |             SAMPLE VALUE |
|:-------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------:|---------:|--------------:|-------------------------:|
| location                                   | Specifies the Azure location where would like to get limits increased.                                                                                                                                                                                                                                                                           | `string` |      n/a |           yes | e.g. "East US", "eastus" |
| zones                                      | The Azure logicalZones would like to get limits increased.                                                                                                                                            | `string` |     ""   |            no |               e.g. "1,2" |


### Setting param value 
The following input tfvars *must* be set

Either as `terraform.tfvars` file in same directory
```
location="<Location Name e.g. West US or westus>"
zones="<Zone number. e.g. 1,2>"
```

Or running as command line parameter
```
terraform apply -var="location=westus"  -var="zones=1,2"
```

### Authentication
```
# authenticate AZ cli
az login --tenant <azure-tenant-id>
```
