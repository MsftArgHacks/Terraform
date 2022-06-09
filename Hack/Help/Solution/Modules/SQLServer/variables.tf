variable resource_group_name {}
variable location {}


variable sc_name {}
variable sqlserver_name {}
variable "admin_username" {
}
variable "admin_password" {
}

variable db_name {}
variable sql_database_edition {}
variable sqldb_service_objective_name {}
variable tags {}
variable firewall_rules {
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable extaudit_diag_logs {
  default     = ["SQLSecurityAuditEvents", "SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors", "DatabaseWaitStatistics", "Timeouts", "Blocks", "Deadlocks"]
}

variable log_analytics_workspace_id {}
variable log_retention_days {}

locals {
    version = "12.0"
    tls_version = "1.2"
}