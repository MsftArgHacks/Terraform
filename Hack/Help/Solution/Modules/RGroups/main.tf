resource "azurerm_resource_group" "mshack" {
  for_each = var.tupla_rgname_lc
  name     = each.value.name
  location = each.value.location
}