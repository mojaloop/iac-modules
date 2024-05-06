output "mojaloop_output_path" {
  value = local.output_path
}
output "mojaloop_sync_wave" {
  value = var.mojaloop_sync_wave
}
output "mojaloop_kafka_host" {
  value = "${module.mojaloop_stateful_resources.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
}
output "mojaloop_kafka_port" {
  value = module.mojaloop_stateful_resources.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_port
}

output "debug_ext_svc_cnt" {
  value =  local.ext_sts_svc_count
}

output "ext_sts_addresses" {
  value =  local.ext_sts_addresses
}

output "ext_sts_addresses2" {
  value =  local.ext_sts_addresses2
}