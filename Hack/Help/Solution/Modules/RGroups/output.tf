output "id" {
  value       = "${azurerm_resource_group.mshack[*]}"
  description = "The resource group ID"
}

output "name" {
  value       = "${azurerm_resource_group.mshack[*]}"
  description = "The name of the resource group."
}
