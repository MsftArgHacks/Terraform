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



