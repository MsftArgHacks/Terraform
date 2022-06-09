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

//Generation of ramdom String KeyVault
resource "random_string" "kv_name_subfix" {
  length  = 18
  special = false
  upper   = false
  number  = true
}
//Generation of ramdom String App Service
resource "random_string" "str" {
  length  = 3
  special = false
  upper   = false
  number  = false
}
//Declaration of Locals Variables.
locals {

  kv_name = join("", ["kv", random_string.kv_name_subfix.result])
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
  name                  = var.loganalytics_name
  depends_on            = [module.RGroups] // Dependencia Explicita.
  resource_group_name   = join("," , module.RGroups.name[*].RGEU2001.name) // Dependencia implicita
  location              = join("," , module.RGroups.name[*].RGEU2001.location) // Dependencia implicita
  sku                   = "Free"
  //retention_in_days     = 7
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
  sqlserver_name               = var.sqlserver_name == null ? "sqlserver${random_string.str.result}" : var.sqlserver_name
  db_name                      = var.db_name
  admin_username               = var.admin_username 
  admin_password               = var.admin_password 
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
  asp_name = "${var.asp_name}${substr(each.value.location, 0, 4)}"
  wa_name  = "${var.wa_name}${substr(each.value.location, 0, 4)}"
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
  },
  {
    name = "KV"
    type = "Custom"
    //Referenciamos al secreto (cnnstr) del KV con el cnn str
    value = format("@Microsoft.KeyVault(VaultName=%s;SecretName=cnnstr)",local.kv_name)
  }]
  app_insights_name = "${random_string.str.result}app_insights"
  application_insights_type = "web"
  //workspace_id = module.LogAnalitycs.workspace_id
}


//KeyVault
module "KeyVault" {
  source              = "./Modules/KeyVault"
  name                = var.kv_name
  depends_on          = [module.RGroups, module.SQLServer, module.Appservice]
  location            = join("," , module.RGroups.name[*].RGEU2001.location) // Dependencia implicita
  resource_group_name = join("," , module.RGroups.name[*].RGEU2001.name) // Dependencia implicita
  tenant_id           = module.Appservice.RGEU2001.app_tenant_id[0] //var.tenant_id
  serviceppal_id      = module.Appservice.RGEU2001.app_sp[0] //var.serviceppal_id
  serviceppal_id_cu   = module.Appservice.RGCU001.app_sp[0] //var.serviceppal_id
  sql_cnn_str         = module.SQLServer.connection_string
}


//FrontDoor
module "Frontdoor" {
  source  = "./modules/FrontDoor"
  tags     = merge(local.common_tags)
  frontdoorname = var.frontdoor_name
  location = "Global"
  resource_group_name = join("," , module.RGroups.name[*].RGEU2001.name) // Dependencia implicita
  enforcebpcert = "false"
  backendpoolname = "myservers"
  acceptedprotocols = ["Http"]
  patternstomatch = ["/*"]
  frontend_endpoint = {
    name      = var.frontdoor_name
    host_name = "${var.frontdoor_name}.azurefd.net"
  }
///////////////////////////
routing_rule = {
    rr1 = {
      name               = var.frontdoor_name
      frontend_endpoints = [var.frontdoor_name] 
      accepted_protocols = ["Http", "Https"]                                      
      patterns_to_match  = ["/*"]                                                 
      enabled            = true                                                  
      configuration      = "Forwarding"                                            
      forwarding_configuration = {
        backend_pool_name                     = "misservers"
        cache_enabled                         = false                             
        cache_use_dynamic_compression         = false                             
        cache_query_parameter_strip_directive = "StripNone"                      
        custom_forwarding_path                = ""
        forwarding_protocol                   = "MatchRequest"                    
      }
      redirect_configuration = {
        custom_host         = ""                                                  
        redirect_protocol   = "MatchRequest"                                        
        redirect_type       = "Found"                                            
        custom_path         = ""
        custom_query_string = ""
      }
    }                                                                            
  }

///////////////////////////
  backend_pool_load_balancing = {
    lb1 = {
      name                            = "exampleLoadBalancingSettings1"
      sample_size                     = 4                                        
      successful_samples_required     = 2                                        
      additional_latency_milliseconds = 0                                         
    }                                                                             
  }
///////////////////////////

  backend_pool_health_probe = {
    hp1 = {
      name                = "exampleHealthProbeSetting1"
      path                = "/"
      protocol            = "Http"       
      interval_in_seconds = 120            
    }                                      
  }
////////////////////////////
front-door-object-backend-pool = {
   backend_pool = {
    bp1 = {
      name = "misservers"
      backend = {
         app1 = {
          enabled     = true
          address     = join("," , module.Appservice.*.RGCU001.app_service_default_site_hostname)
          host_header = join("," , module.Appservice.*.RGCU001.app_service_default_site_hostname)
          http_port   = 80
          https_port  = 443
          priority    = 1       
          weight      = 50 
          },
         app2 = {
          enabled     = true
          address     = join("," , module.Appservice.*.RGEU2001.app_service_default_site_hostname)
          host_header = join("," , module.Appservice.*.RGEU2001.app_service_default_site_hostname)
          http_port   = 80
          https_port  = 443
          priority    = 1  
          weight      = 50 
          }                                                                       
      }
    load_balancing_name = "exampleLoadBalancingSettings1"                    
    health_probe_name   = "exampleHealthProbeSetting1" 

    }                                                                            
  }
}
}
