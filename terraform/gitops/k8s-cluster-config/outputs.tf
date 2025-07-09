output "mojaloop_output_path" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_output_path : ""
}
output "mojaloop_sync_wave" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_sync_wave : 0
}
output "mojaloop_kafka_host" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_kafka_host : ""
}
output "mojaloop_kafka_port" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_kafka_port : ""
}
output "storage_class_name" {
  value = var.storage_class_name
}

output "mojaloop_stateful_resources" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].stateful_resources : null
}

output "common_stateful_resources" {
  value = module.common_stateful_resources.stateful_resources
}

# DEBUG: Add SMTP configuration debug output to logs
output "debug_smtp_config" {
  value = {
    smtp_variable_received = var.smtp
    smtp_from             = try(var.smtp.from, "NOT_SET")
    smtp_host             = try(var.smtp.host, "NOT_SET") 
    smtp_port             = try(var.smtp.port, "NOT_SET")
    smtp_auth             = try(var.smtp.auth, "NOT_SET")
    debug_message         = "This should show your custom SMTP config from mojaloop-vars.yaml"
  }
  description = "Debug output to verify SMTP configuration is being passed correctly"
}