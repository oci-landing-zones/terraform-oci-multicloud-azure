resource "azapi_resource" "this" {
  type      = "Oracle.Database/resourceAnchors@2025-09-01"
  name      = var.name
  parent_id = var.resource_group_id
  location  = "global"
  tags      = var.tags
  body = {
    properties = {}
  }
}
