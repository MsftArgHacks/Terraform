output "frontend_endpoints" {
  value = azurerm_frontdoor.mshack.frontend_endpoint[0].name
}

