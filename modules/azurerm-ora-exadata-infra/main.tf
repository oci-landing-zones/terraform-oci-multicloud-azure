# https://github.com/hashicorp/terraform-provider-azurerm/releases
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.6.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

resource "azurerm_oracle_exadata_infrastructure" "this" {
  # Required 
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = [var.zone]

  name                = var.name
  display_name        = var.name

  shape         = var.shape
  compute_count = var.compute_count
  storage_count = var.storage_count

  # Optional
  customer_contacts  = var.customer_contacts
  tags               = var.tags

  maintenance_window {
      patching_mode = var.maintenance_window.patching_mode
      preference = var.maintenance_window.preference
      lead_time_in_weeks = coalesce(var.maintenance_window.lead_time_in_weeks,1) 
      months = coalesce(var.maintenance_window.months,[])
      weeks_of_month = coalesce(var.maintenance_window.weeks_of_month,[])
      days_of_week = coalesce(var.maintenance_window.days_of_week,[])
      hours_of_day = coalesce(var.maintenance_window.hours_of_day,[])
  }
  
  lifecycle {
    ignore_changes = [
      # Updatable from OCI
      compute_count,
      storage_count,
      customer_contacts,
      maintenance_window
    ]
  }
}

resource "terraform_data" oracle_exadata_infrastructure_keeper {
  triggers_replace = [{
    compute_count = var.compute_count,
    storage_count = var.storage_count,
    customer_contacts = var.customer_contacts,
    maintenance_window = {
      patching_mode = var.maintenance_window.patching_mode
      preference = var.maintenance_window.preference
      lead_time_in_weeks = coalesce(var.maintenance_window.lead_time_in_weeks,1) 
      months = coalesce(var.maintenance_window.months,[])
      weeks_of_month = coalesce(var.maintenance_window.weeks_of_month,[])
      days_of_week = coalesce(var.maintenance_window.days_of_week,[])
      hours_of_day = coalesce(var.maintenance_window.hours_of_day,[])
    }
  }]
}

resource "azapi_update_resource" "oracle_exadata_infrastructure" {
  type = "Oracle.Database/cloudExadataInfrastructures@2024-06-01"
  resource_id = azurerm_oracle_exadata_infrastructure.this.id
  body = {
    properties = {
      computeCount = var.compute_count
      storageCount = var.storage_count
      customerContacts = var.customer_contacts,
      maintenanceWindow = {
        preference = var.maintenance_window.preference
        months = coalesce(var.maintenance_window.months,[])
        weeksOfMonth = coalesce(var.maintenance_window.weeks_of_month,[])
        daysOfWeek = coalesce(var.maintenance_window.days_of_week,[])
        hoursOfDay = coalesce(var.maintenance_window.hours_of_day,[])
        leadTimeInWeeks = coalesce(var.maintenance_window.lead_time_in_weeks,1) 
        patchingMode = var.maintenance_window.patching_mode
      }
    }
  }
  lifecycle {
    ignore_changes = all
    replace_triggered_by = [
      terraform_data.oracle_exadata_infrastructure_keeper.id
    ]
  }
}

data "azurerm_oracle_exadata_infrastructure" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_oracle_exadata_infrastructure.this]
}