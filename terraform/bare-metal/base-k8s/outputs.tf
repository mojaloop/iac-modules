output "nat_public_ips" {
  description = "nat gateway public ips"
  value       = var.app_var_map.nat_public_ips
}

output "internal_load_balancer_dns" {
  value = var.app_var_map.internal_load_balancer_dns
}

output "external_load_balancer_dns" {
  value = var.app_var_map.external_load_balancer_dns
}

output "private_subdomain" {
  value = var.app_var_map.private_subdomain
}

output "public_subdomain" {
  value = var.app_var_map.public_subdomain
}

output "internal_interop_switch_fqdn" {
  value = "${var.app_var_map.int_interop_switch_subdomain}.${trimsuffix(var.app_var_map.private_subdomain, ".")}"
}

output "external_interop_switch_fqdn" {
  value = "${var.app_var_map.ext_interop_switch_subdomain}.${trimsuffix(var.app_var_map.public_subdomain, ".")}"
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
  value = var.app_var_map.private_network_cidr
}

output "dns_provider" {
  value = var.dns_provider
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
  value     = local.secrets_var_map
}

output "properties_var_map" {
  value = local.properties_var_map
}

output "properties_key_map" {
  value = local.post_config_properties_key_map
}

output "secrets_key_map" {
  value = local.post_config_secrets_key_map
}

output "all_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_user             = var.app_var_map.os_user_name
    ansible_ssh_retries          = "10"
    base_domain                  = var.app_var_map.base_domain
    internal_interop_switch_fqdn = "${var.app_var_map.int_interop_switch_subdomain}.${var.app_var_map.base_domain}"
    external_interop_switch_fqdn = "${var.app_var_map.ext_interop_switch_subdomain}.${var.app_var_map.base_domain}"
    kubeapi_loadbalancer_fqdn    = var.app_var_map.kubeapi_loadbalancer_fqdn
  }
}

output "agent_hosts_var_maps" {
  sensitive = true
  value = {
    master_ip = var.app_var_map.master_hosts_0_private_ip
  }
}

output "agent_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_common_args        = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr            = var.app_var_map.egress_gateway_cidr
    haproxy_external_ip            = var.app_var_map.haproxy_external_ip
    haproxy_internal_ip            = var.app_var_map.haproxy_internal_ip
    enable_external_ingress_k8s_lb = var.app_var_map.enable_external_ingress_k8s_lb
    enable_internal_ingress_k8s_lb = var.app_var_map.enable_internal_ingress_k8s_lb
    enable_external_egress_lb      = var.app_var_map.enable_external_egress_lb
  }
}

output "bastion_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts" {
  value = { bastion = var.app_var_map.bastion_public_ip }
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
    k6s_callback_fqdn      = var.app_var_map.k6s_callback_fqdn
  } : {}
}

locals {

  secrets_var_map = {
    route53_external_dns_access_key = var.app_var_map.route53_external_dns_access_key
    route53_external_dns_secret_key = var.app_var_map.route53_external_dns_secret_key
    longhorn_backups_access_key     = var.app_var_map.longhorn_backups_access_key
    longhorn_backups_secret_key     = var.app_var_map.longhorn_backups_secret_key
  }


  properties_var_map = {
    longhorn_backups_bucket_name                = var.app_var_map.longhorn_backups_bucket_name
    external_dns_credentials_client_id_name     = var.app_var_map.external_dns_credentials_client_id_name
    external_dns_credentials_client_secret_name = var.app_var_map.external_dns_credentials_client_secret_name
    cert_manager_credentials_client_id_name     = var.app_var_map.cert_manager_credentials_client_id_name
    cert_manager_credentials_client_secret_name = var.app_var_map.cert_manager_credentials_client_secret_name
  }

  post_config_secrets_key_map = {
    external_dns_cred_id_key         = "route53_external_dns_access_key"
    external_dns_cred_secret_key     = "route53_external_dns_secret_key"
    longhorn_backups_cred_id_key     = "longhorn_backups_access_key"
    longhorn_backups_cred_secret_key = "longhorn_backups_secret_key"
  }

  post_config_properties_key_map = {
    longhorn_backups_bucket_name_key = "longhorn_backups_bucket_name"
  }
}
