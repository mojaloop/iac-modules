output "mojaloop_output_path" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_output_path : ""
}
output "mojaloop_sync_wave" {
  value = var.common_var_map.mojaloop_enabled ? module.mojaloop[0].mojaloop_sync_wave : 0
}
