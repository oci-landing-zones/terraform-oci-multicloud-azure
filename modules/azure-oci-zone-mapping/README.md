# exadata-limits
Terraform Template to get info for exadata limits raising.

## Providers

| Name | Version |
|------|---------|
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | n/a |


## Inputs Variables 

| VARIABLE                                  |                                                                                                                                                                   DESCRIPTION                                                                                                                                                                   | Type | REQUIRED | DEFAULT_VALUE |             SAMPLE VALUE |
|:------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------:|---------:|--------------:|-------------------------:|
| location                                  |                                                                                                                                     Specifies the Azure location where would like to get limits increased.                                                                                                                                      | `string` |      n/a |           yes | e.g. "East US", "eastus" |
| zone                                      |                                                                                                                                            The Azure logicalZone would like to get limits increased.                                                                                                                                            | `string` |     ""   |            no |                 e.g. "1" |


### Setting param value 
The following input tfvars *must* be set

Either as `terraform.tfvars` file in same directory
```
location="<Location Name e.g. West US or westus>"
zone="<Zone number. e.g. 1>"
```

Or running as command line parameter
```
terraform apply -var="location=westus"  -var="zone=1"
```

### Authentication
```
# authenticate AZ cli
az login --tenant <azure-tenant-id>
```

## Outputs

| Name                  | Description                                                                                      |
|-----------------------|--------------------------------------------------------------------------------------------------|
| location_zone_mapping | Availability zone mappings for the region.  The map of logical_zone and physical_zone.           |
| internal_ad           | OCI AD which logical zone id is mapped to.                                                       |
| az_physical_zone      | The fully qualified physical zone id of availability zone to which logical zone id is mapped to. |
| region                | Region which var.location is mapped to.                                                          |
| region_id                | Region ID which var.location is mapped to.                                                          |
| logical_zone          | The logical zone id for the availability zone.                                                   |

## Troubleshooting
### Known Issues:
