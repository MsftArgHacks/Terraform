output "primary_sql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = azurerm_sql_server.mshack.id
}

output "primary_sql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = azurerm_sql_server.mshack.fully_qualified_domain_name
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = azurerm_sql_server.mshack.administrator_login
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = azurerm_sql_server.mshack.administrator_login_password
  sensitive   = true
}

output "sql_database_id" {
  description = "The SQL Database ID"
  value       = azurerm_sql_database.db.id
}

output "sql_database_name" {
  description = "The SQL Database Name"
  value       = azurerm_sql_database.db.name
}

output "connection_string" {
  description = "Connection string for the Azure SQL Database created."
  value       = "Server=tcp:${azurerm_sql_server.mshack.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.db.name};Persist Security Info=False;User ID=${azurerm_sql_server.mshack.administrator_login};Password=${azurerm_sql_server.mshack.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

output "random_string" {
  description = "The SQL Database Name"
  value       = random_string.str.result
}