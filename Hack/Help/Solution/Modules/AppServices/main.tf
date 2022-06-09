resource "azurerm_application_insights" "mshack" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_insights_type
  //workspace_id        = var.workspace_id
}

resource "azurerm_app_service_plan" "mshack" {
  name                = var.asp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier              = lookup(var.sku, "tier")
    size              = lookup(var.sku, "size")
  }
}

resource "azurerm_app_service" "mshack" {
  name                = var.wa_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.mshack.id
  
  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      always_on                   = lookup(site_config.value, "always_on", null)
      dotnet_framework_version    = lookup(site_config.value, "dotnet_framework_version", null)
      scm_type                    = lookup(site_config.value, "None", null)
    }
  }

  app_settings =  merge(local.default_app_settings, var.app_settings)
  
  dynamic "connection_string" {
    for_each = var.connection_string
    content {
      name  = lookup(connection_string.value, "name", null)
      type  = lookup(connection_string.value, "type", null)
      value = lookup(connection_string.value, "value", null)
    }
  }
}

