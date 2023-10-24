output "nat_public_ips" {
  description = "nat gateway public ips"
  value       = module.base_infra.nat_public_ips
}

output "internal_load_balancer_dns" {
  value = aws_lb.internal.dns_name
}

output "external_load_balancer_dns" {
  value = aws_lb.lb.dns_name
}

output "private_subdomain" {
  value = module.base_infra.private_zone.name
}

output "public_subdomain" {
  value = module.base_infra.public_zone.name
}

output "internal_interop_switch_fqdn" {
  value = "${var.int_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
}

output "external_interop_switch_fqdn" {
  value = "${var.ext_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
}

output "target_group_internal_https_port" {
  value = var.app_var_map.target_group_internal_https_port
}
output "target_group_internal_http_port" {
  value = var.app_var_map.target_group_internal_http_port
}
output "target_group_external_https_port" {
  value = var.app_var_map.target_group_external_https_port
}
output "target_group_external_http_port" {
  value = var.app_var_map.target_group_external_http_port
}

output "target_group_internal_health_port" {
  value = var.app_var_map.target_group_internal_health_port
}
output "target_group_external_health_port" {
  value = var.app_var_map.target_group_external_health_port
}

output "private_network_cidr" {
  value = var.app_var_map.vpc_cidr
}

###new items

output "bastion_ssh_key" {
  sensitive = true
  value     = var.app_var_map.ssh_private_key
}

output "bastion_public_ip" {
  value = var.app_var_map.bastion_public_ip
}

output "bastion_os_username" {
  value = var.app_var_map.os_user_name
}

output "haproxy_server_fqdn" {
  value = var.app_var_map.haproxy_server_fqdn
}

output "master_hosts_var_maps" {
  value = {}
}

output "master_hosts_yaml_maps" {
  value = {}
}

output "secrets_var_map" {
  sensitive = true
  value     = module.post_config.secrets_var_map
}

output "properties_var_map" {
  value = module.post_config.properties_var_map
}

output "properties_key_map" {
  value = module.post_config.post_config_properties_key_map
}

output "secrets_key_map" {
  value = module.post_config.post_config_secrets_key_map
}

output "all_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_user             = var.app_var_map.os_user_name
    ansible_ssh_retries          = "10"
    base_domain                  = var.app_var_map.base_domain
    internal_interop_switch_fqdn = "${var.app_var_map.int_interop_switch_subdomain}.${var.app_var_map.base_domain}"
    external_interop_switch_fqdn = "${vvar.app_var_map.ext_interop_switch_subdomain}.${var.app_var_map.base_domain}"
    kubeapi_loadbalancer_fqdn    = var.app_var_map.dns_name
  }
}

output "agent_hosts_var_maps" {
  sensitive = true
  value = {
    master_ip = var.app_var_map.master_hosts[0].private_ip
  }
}

output "agent_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.app_var_map.egress_gateway_cidr
    haproxy_external_ip     = var.app_var_map.haproxy_external_ip
    haproxy_internal_ip     = var.app_var_map.haproxy_internal_ip
  }
}

output "bastion_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts" {
  value = { bastion = var.app_var_map.haproxy_external_ip }
}

output "agent_hosts" {
  value = var.app_var_map.agent_hosts
}

output "master_hosts" {
  value = var.app_var_map.master_hosts
}

output "test_harness_hosts" {
  value = var.app_var_map.enable_k6s_test_harness ? { test_harness = var.app_var_map.test_harness_private_ip } : {}
}

output "test_harness_hosts_var_maps" {
  value = var.app_var_map.enable_k6s_test_harness ? {
    docker_extra_vol_mount = false
    k6s_callback_fqdn = var.app_var_map.k6s_callback_fqdn
  } : {}
}
