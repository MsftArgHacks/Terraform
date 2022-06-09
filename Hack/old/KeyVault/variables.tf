variable "location" {}

variable "resource_group_name" {}

variable "tenant_id" {
  default = ""
}

variable "serviceppal_id" {
  description = "Es el object id de la cuenta en AAD."
  default = ""
}

variable "serviceppal_id_cu" {
  description = "Es el object id de la cuenta en AAD."
  default = ""
}
variable "sql_cnn_str" {
  description = "SQL Server connection string."
  type        = string
  sensitive   = true
}

variable "name" {
  description = "Nombre del KeyVault."
  type        = string
}