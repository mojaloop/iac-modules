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
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].stateful_resources : []
}

output "common_stateful_resources" {
  value = module.common_stateful_resources.stateful_resources
}