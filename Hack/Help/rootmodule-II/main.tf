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
//Generation of ramdom String
resource "random_string" "str" {
  length  = 3
  special = false
  upper   = false
  number  = false
}
//Declaration of Locals Variables.
locals {
  sqlserver_name = "haargsql"
  common_tags = {
    environment = "${var.prefix}"
    project     = "${var.project}"
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
  extra_tags = {
    network = "HackTest"
    extra = "Terraform"
  }
}

//RG
module "RGroups" {
  source = "./Modules/RGroups"
  tupla_rgname_lc = var.tupla_rgname_lc
}

//Log Analytics
module "LogAnalitycs" {
  source                = "./Modules/LogAnalitycs"
  name                  = "mshack"
  depends_on            = [module.RGroups] // Dependencia Explicita.
  resource_group_name   = join("," , module.RGroups.name[*].RGEU2001.name) // Dependencia implicita
  location              = join("," , module.RGroups.name[*].RGEU2001.location) // Dependencia implicita
  sku                   = "Free"
  retention_in_days     = 7
  tags = merge(local.common_tags, local.extra_tags)
  solutions = [
        {
            solution_name = "AzureActivity",
            publisher = "Microsoft",
            product = "OMSGallery/AzureActivity",
        },
    ]
}
//SQLServer
module "SQLServer" {
  source                       = "./Modules/SQLServer"
  depends_on                   = [module.RGroups, module.LogAnalitycs]
  location                     = join("," , module.RGroups.name[*].RGEU2001.location)  
  sc_name                      = "holaychao"
  sqlserver_name               =  local.sqlserver_name == null ? random_string.str.result : local.sqlserver_name
  db_name                      = "demomssqldb"
  sql_database_edition         = "Standard" 
  sqldb_service_objective_name = "S1"
  resource_group_name          = join("," , module.RGroups.name[*].RGEU2001.name) 

  log_analytics_workspace_id    = module.LogAnalitycs.resource_id
  log_retention_days            = 7
  
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "190.233.207.107"
      end_ip_address   = "190.233.207.107"
    }
  ]

  #initialize_sql_script_execution = true
  #sqldb_init_script_file          = "../artifacts/db-init-sample.sql"

  tags = merge(local.common_tags, local.extra_tags)
}
//AppServices
module "Appservice" {
  for_each = var.tupla_rgname_lc
  source  = "./Modules/AppServices"
  depends_on  = [module.RGroups, module.SQLServer]
  asp_name = "${each.value.location}${random_string.str.result}asp"
  wa_name  = "${each.value.location}${random_string.str.result}app"
  location = each.value.location
  resource_group_name = each.value.name
  sku = {
    tier = "Standard"
    size = "S1"
  }
  site_config = {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }
  app_settings = {
    foo = "bar"
  }
  connection_string = [{
    name = "SQLServer"
    type = "SQLAzure"
    value = module.SQLServer.connection_string
  }]
  app_insights_name = "${random_string.str.result}app_insights"
  application_insights_type = "web"
  //workspace_id = module.LogAnalitycs.workspace_id
}
