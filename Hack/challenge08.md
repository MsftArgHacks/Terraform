# Azure + GitHub + Terraform:

## Challenge 8 – Front Door

[Back](/Hack/challenge07.md) - [Home](readme.md) - [Solution](Solutions.md)

### What is Azure Front Door?

Azure Front Door is a global, scalable entry-point that uses the Microsoft global edge network to create fast, secure, and widely scalable web applications. With Front Door, you can transform your global consumer and enterprise applications into robust, high-performing personalized modern applications with contents that reach a global audience through Azure.

![Image alt text](../Hack/Images/front-door-visual-diagram.PNG)

Front Door works at Layer 7 (HTTP/HTTPS layer) using anycast protocol with split TCP and Microsoft's global network to improve global connectivity. Based on your routing method you can ensure that Front Door will route your client requests to the fastest and most available application backend. An application backend is any Internet-facing service hosted inside or outside of Azure. Front Door provides a range of traffic-routing methods and backend health monitoring options to suit different application needs and automatic failover scenarios. Similar to Traffic Manager, Front Door is resilient to failures, including failures to an entire Azure region.

### Terraform and Front Door?

For the insfrastructure of this hackathon will be neccesary have two App Services as a backend of Front Door.
We recommend check the declaration of front door and example on github.

- [Terraform and Front Door.](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor)
- [Github, Terraform, FrontDoor](https://github.com/aztfmod/terraform-azurerm-caf-frontdoor)

#### Front Door Module:

### main.tf:

```
resource "azurerm_frontdoor" "mshack" {
   name                                         = var.frontdoorname
   location                                     = var.location
   resource_group_name                          = var.resource_group_name
   enforce_backend_pools_certificate_name_check = var.enforcebpcert

  frontend_endpoint {
  name              = lookup(var.frontend_endpoint, "name")
  host_name         = lookup(var.frontend_endpoint, "host_name")
  }

  backend_pool_load_balancing {
  name = "${var.backendpoolname}LBSetting"
  }

  backend_pool_health_probe {
  name = "${var.backendpoolname}HealthSetting"
  }


////////////////////////////////////////////
dynamic "routing_rule" {
    for_each = var.routing_rule
    content {
      name               = routing_rule.value.name
      accepted_protocols = routing_rule.value.accepted_protocols
      patterns_to_match  = routing_rule.value.patterns_to_match
      frontend_endpoints = routing_rule.value.frontend_endpoints
      dynamic "forwarding_configuration" {
        for_each = routing_rule.value.configuration == "Forwarding" ? [routing_rule.value.forwarding_configuration] : []
        content {
          backend_pool_name                     = routing_rule.value.forwarding_configuration.backend_pool_name
          cache_enabled                         = routing_rule.value.forwarding_configuration.cache_enabled
          cache_use_dynamic_compression         = routing_rule.value.forwarding_configuration.cache_use_dynamic_compression #default: false
          cache_query_parameter_strip_directive = routing_rule.value.forwarding_configuration.cache_query_parameter_strip_directive
          custom_forwarding_path                = routing_rule.value.forwarding_configuration.custom_forwarding_path
          forwarding_protocol                   = routing_rule.value.forwarding_configuration.forwarding_protocol
        }
      }
      dynamic "redirect_configuration" {
        for_each = routing_rule.value.configuration == "Redirecting" ? [routing_rule.value.redirect_configuration] : []
        content {
          custom_host         = routing_rule.value.redirect_configuration.custom_host
          redirect_protocol   = routing_rule.value.redirect_configuration.redirect_protocol
          redirect_type       = routing_rule.value.redirect_configuration.redirect_type
          custom_fragment     = routing_rule.value.redirect_configuration.custom_fragment
          custom_path         = routing_rule.value.redirect_configuration.custom_path
          custom_query_string = routing_rule.value.redirect_configuration.custom_query_string
        }
      }
    }
  }

////////////////////////////////////////////
 dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pool_load_balancing
    content {
      name                            = backend_pool_load_balancing.value.name
      sample_size                     = backend_pool_load_balancing.value.sample_size
      successful_samples_required     = backend_pool_load_balancing.value.successful_samples_required
      additional_latency_milliseconds = backend_pool_load_balancing.value.additional_latency_milliseconds
    }
  }
 ////////////////////////////////////////////
 dynamic "backend_pool_health_probe" {
    for_each = var.backend_pool_health_probe
    content {
      name                = backend_pool_health_probe.value.name
      path                = backend_pool_health_probe.value.path
      protocol            = backend_pool_health_probe.value.protocol
      interval_in_seconds = backend_pool_health_probe.value.interval_in_seconds
    }
  }
//////////////////////////////////////////////
    dynamic "backend_pool" {
    for_each = var.front-door-object-backend-pool.backend_pool
    content {
      name                = backend_pool.value.name
      load_balancing_name = backend_pool.value.load_balancing_name
      health_probe_name   = backend_pool.value.health_probe_name

      dynamic "backend" {
        for_each = backend_pool.value.backend
        content {
          enabled     = backend.value.enabled
          address     = backend.value.address
          host_header = backend.value.host_header
          http_port   = backend.value.http_port
          https_port  = backend.value.https_port
          priority    = backend.value.priority
          weight      = backend.value.weight
        }
      }
    }
  }
}


//reference: https://github.com/aztfmod/terraform-azurerm-caf-frontdoor


```

### variables.tf:

```
variable "frontdoorname" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "enforcebpcert" {
  type    = string
  default = "false"
}

variable "tags" {
  type = map(any)
}

///////Backend Pool
variable "backendpoolname" {
  type = string
}
///////

variable "acceptedprotocols" {
  type    = list(string)
  default = ["Http"]
}

variable "patternstomatch" {
  type    = list(string)
  default = ["/*"]
}

variable "front-door-object-backend-pool" {
}
variable "routing_rule" {
}

variable "frontend_endpoint"{
  type    = map(string)
}

variable "backend_pool_load_balancing" {
}
variable "backend_pool_health_probe" {
}

```

### output.tf:

```
output "frontend_endpoints" {
  value = azurerm_frontdoor.mshack.frontend_endpoint[0].name
}

```

### Calling Front Door Module from Root Module:

```

//FrontDoor
module "Frontdoor" {
  source  = "./modules/FrontDoor"
  tags     = merge(local.common_tags)
  frontdoorname = var.frontdoorname
  location = "Global"
  resource_group_name = join("," , module.RGroups.name[*].RGEU2001.name) // Dependencia implicita
  enforcebpcert = "false"
  backendpoolname = "myservers"
  acceptedprotocols = ["Http"]
  patternstomatch = ["/*"]
  frontend_endpoint = {
    name      = var.frontdoorname
    host_name = "${var.frontdoorname}.azurefd.net"
  }
///////////////////////////
 routing_rule = {
    rr1 = {
      name               = var.frontdoorname
      frontend_endpoints = [var.frontdoorname]
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


```

Note: if you use the example exposed before, you will need at a variable on the variable.tf in the root module:

```
//Variable FrontDoor

variable frontdoorname {
  type = string
}
```

### Challenge

In this challenge you will need to create front door module based the Terraform references or copy the front door previosly exporsed and incorporate on the GitHub Repo and Actions workflow.

1. Create the terraform module in GitHub.
2. Integrate the module to the rest of the solution. Add to the CI/CD Pipeline.
3. Deploy the front door.
4. Try the access to the app using front door.

### Success Criteria

1. You should have to have the Front Door Module addded to the rest of the infrastructure.
2. You should have created all the infrastructure in Azure and the app.
3. Using the url of Front Door, you will be able to access to the application.

[Back](/Hack/challenge07.md) - [Home](readme.md) - [Solution](Solutions.md)
