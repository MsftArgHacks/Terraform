variable location {}
variable resource_group_name {}
variable app_insights_name {}
variable application_insights_type {}

//App Service Plan
variable asp_name {}
//SKU
variable sku {
  type = map(string)
}

//App Service 
variable wa_name {}

variable site_config {
  type = any
}

variable app_settings {
  type = map(string)
}

variable connection_string {
  type = list(map(string))
}

locals {
  default_app_settings = {
    APPLICATION_INSIGHTS_IKEY   = "${azurerm_application_insights.mshack.instrumentation_key}"
    APPINSIGHTS_INSTRUMENTATIONKEY = "${azurerm_application_insights.mshack.instrumentation_key}"
  }
}