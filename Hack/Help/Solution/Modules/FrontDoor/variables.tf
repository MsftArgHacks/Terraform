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

//////

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

