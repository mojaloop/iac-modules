output "mojaloop_output_path" {
  value = local.output_path
}
output "mojaloop_sync_wave" {
  value = var.mojaloop_sync_wave
}
output "mojaloop_kafka_host" {
  value = "${try(module.mojaloop_stateful_resources.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_name,null)}.${var.stateful_resources_namespace}.svc.cluster.local"
}
output "mojaloop_kafka_port" {
  value = try(module.mojaloop_stateful_resources.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_port,null)
}
