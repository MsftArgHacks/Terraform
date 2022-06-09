//Backend Example.
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "hackterraform"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"    
  }
  required_providers {
    azurerm = {
      version = "~> 2.19"
    }
  }
}

//Provider example
provider "azurerm" {
  features {}
}

