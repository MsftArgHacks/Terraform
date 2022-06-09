variable name {}
variable resource_group_name {}
variable location {}
variable sku {}
//variable retention_in_days {}
variable tags {}
variable solutions {
  type        = list(object({ solution_name = string, publisher = string, product = string }))
  default     = []
}

