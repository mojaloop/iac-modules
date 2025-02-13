output "secrets_var_map" {
  sensitive = true
  value     = ( length(local.rds_services) > 0 || length(local.mongodb_services) > 0 || length(local.monolith_rds_services) > 0 ) ? merge(try(module.deploy_rds_ms[0].secrets_var_map,{}), try(module.deploy_mongodb[0].secrets_var_map,{}), try(module.deploy_rds_monolith[0].secrets_var_map,{})) : {}
}

output "properties_var_map" {
  value = ( length(local.rds_services) > 0 || length(local.msk_services) > 0 || length(local.mongodb_services) > 0 || length(local.monolith_rds_services) > 0 ) ? merge(try(module.deploy_rds_ms[0].properties_var_map, {}), try(module.deploy_msk[0].properties_var_map , {}), try(module.deploy_mongodb[0].properties_var_map , {}), try(module.deploy_rds_monolith[0].properties_var_map,{})) : {}
}

output "secrets_key_map" {
  value = ( length(local.rds_services) > 0 || length(local.mongodb_services) > 0 || length(local.monolith_rds_services) > 0 ) ? merge(try(module.deploy_rds_ms[0].secrets_key_map,{}), try(module.deploy_mongodb[0].secrets_key_map,{}), try(module.deploy_rds_monolith[0].secrets_key_map,{})) : {}
}

output "monolith_secrets_var_map" {
  sensitive = true
  value     = ( length(local.monolith_rds_services) > 0 ) ?  try(module.deploy_rds_monolith[0].monolith_secrets_var_map,{}) : {}
}

output "monolith_properties_var_map" {
  value = (length(local.monolith_rds_services) > 0 ) ? try(module.deploy_rds_monolith[0].monolith_properties_var_map,{}) : {}
}

output "monolith_secrets_key_map" {
  value = (length(local.monolith_rds_services) > 0 ) ? try(module.deploy_rds_monolith[0].monolith_secrets_key_map,{}) : {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_user        = var.os_user_name
    ansible_ssh_retries     = "10"
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.vpc_cidr
  }
}

output "bastion_hosts" {
  value = zipmap([for i in range(length(module.base_infra[0].bastion_public_ips)) : "bastion${i + 1}"], module.base_infra[0].bastion_public_ips)
}

output "bastion_ssh_key" {
  sensitive = true
  value     = length(local.external_services) > 0 ? module.base_infra[0].ssh_private_key : ""
}

output "bastion_public_ip" {
  value = length(local.external_services) > 0 ?  module.base_infra[0].bastion_public_ip : ""
}

output "bastion_os_username" {
  value = var.os_user_name
}
