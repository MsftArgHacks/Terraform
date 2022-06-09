output "id" {
  value       = azurerm_key_vault.kv.id
  description = "The KV resource ID"
}

output "name" {
  value       = azurerm_key_vault.kv.name
  description = "The KV name"
}

#output "name" {
#  value       = azurerm_key_vault.name
#  description = "The name of the resource."
#}