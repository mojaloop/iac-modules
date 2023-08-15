output "secrets_var_map" {
  sensitive = true
  value = length(local.rds_services) > 0 ? module.deploy_rds[0].secrets_var_map : {}
}

output "properties_var_map" {
  value = length(local.rds_services) > 0 ? module.deploy_rds[0].properties_var_map : {}
}

output "secrets_key_map" {
  value = length(local.rds_services) > 0 ? module.deploy_rds[0].secrets_key_map : {}
}