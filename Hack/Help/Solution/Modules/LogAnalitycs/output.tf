output "resource_id" {
  description = "Id of Log Analytics resource in Azure."
  value       = azurerm_log_analytics_workspace.mshack.id
}

output "workspace_id" {
  description = "Log Analytics Workspace id, this is just a guid."
  value       = azurerm_log_analytics_workspace.mshack.workspace_id
}