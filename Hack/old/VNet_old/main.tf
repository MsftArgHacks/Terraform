resource "azurerm_virtual_network" "example" {
  name                = var.VnetName
  location            = var.Location
  resource_group_name = var.RGName
  address_space       = var.AddressSpace


  subnet {
    name           = var.SubnetName
    address_prefix = var.AddressPrefix
  }  
  tags = var.Tags
}