
resource "azurerm_log_analytics_workspace" "mshack" {
  name                = "${var.name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  //retention_in_days   = var.retention_in_days

  tags = var.tags
}



resource "azurerm_log_analytics_solution" "mshack" {
  count                 = length(var.solutions)
  solution_name         = var.solutions[count.index].solution_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.mshack.id
  workspace_name        = azurerm_log_analytics_workspace.mshack.name

  plan {
    publisher = var.solutions[count.index].publisher
    product   = var.solutions[count.index].product
  }

  tags = var.tags
}