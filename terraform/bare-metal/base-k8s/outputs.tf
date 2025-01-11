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
output "target_group_vpn_port" {
  value = var.app_var_map.wireguard_port
}
output "private_network_cidr" {
  value = var.app_var_map.private_network_cidrs[0]
}

output "internal_k8s_network_cidr" {
  value = var.app_var_map.private_network_cidrs
}

output "ext_dns_cloud_policy" {
  value = var.app_var_map.ext_dns_cloud_policy
}

output "external_dns_cloud_role" {
  value = var.app_var_map.external_dns_cloud_role
}

output "object_storage_cloud_role" {
  value = var.app_var_map.object_storage_cloud_role
}
output "object_storage_bucket_name" {
  value = var.app_var_map.backup_bucket_name
}

###new items

output "bastion_ssh_key" {
  sensitive = true
  value     = var.app_var_map.ssh_private_key
}

output "bastion_public_ip" {
  value = var.app_var_map.bastion_public_ips[0]
}

output "bastion_os_username" {
  value = var.app_var_map.os_user_name
}

output "dns_provider" {
  value = var.app_var_map.dns_provider
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
    dns_resolver_ip              = var.app_var_map.dns_resolver_ip
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
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.app_var_map.egress_gateway_cidr
  }
}

output "bastion_hosts_yaml_maps" {
  value = {
    node_pool_labels = yamlencode(local.node_labels)
    node_pool_taints = yamlencode(local.node_taints)
  }
}

output "bastion_hosts" {
  value = zipmap([for i in range(length(var.app_var_map.bastion_public_ips)) : "bastion${i + 1}"], var.app_var_map.bastion_public_ips)
}

output "agent_hosts" {
  value = { for key, host in var.app_var_map.agent_hosts :
    key => host.ip
  }
}

output "master_hosts" {
  value = { for key, host in var.app_var_map.master_hosts :
    key => host.ip
  }
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


output "private_subnets" {
  value = var.app_var_map.private_network_cidrs
}

output "vpc_id" {
  value = "unused"
}

locals {

  secrets_var_map = merge(var.app_var_map.create_iam_user ? {
    iac_user_key_id     = var.app_var_map.ci_iam_user_access_key
    iac_user_key_secret = var.app_var_map.ci_iam_user_secret_key
    } : {}, var.app_var_map.create_ext_dns_user ? {
    route53_external_dns_access_key = var.app_var_map.route53_external_dns_access_key
    route53_external_dns_secret_key = var.app_var_map.route53_external_dns_secret_key
  } : {})



  properties_var_map = merge(var.app_var_map.create_iam_user ? {
    ci_user_client_id_name     = var.app_var_map.ci_iam_user_client_id_name
    ci_user_client_secret_name = var.app_var_map.ci_iam_user_client_secret_name
    } : {}, var.app_var_map.create_ext_dns_user ? {
    external_dns_credentials_client_id_name     = var.app_var_map.external_dns_credentials_client_id_name
    external_dns_credentials_client_secret_name = var.app_var_map.external_dns_credentials_client_secret_name
    cert_manager_credentials_client_id_name     = var.app_var_map.cert_manager_credentials_client_id_name
    cert_manager_credentials_client_secret_name = var.app_var_map.cert_manager_credentials_client_secret_name
  } : {})


  post_config_secrets_key_map = merge(var.app_var_map.create_iam_user ? {
    iac_user_cred_id_key     = "iac_user_key_id"
    iac_user_cred_secret_key = "iac_user_key_secret"
    } : {}, var.app_var_map.create_ext_dns_user ? {
    external_dns_cred_id_key     = "route53_external_dns_access_key"
    external_dns_cred_secret_key = "route53_external_dns_secret_key"
  } : {})


  post_config_properties_key_map = merge(var.app_var_map.create_iam_user ? {
    ci_user_client_id_name_key     = "ci_user_client_id_name"
    ci_user_client_secret_name_key = "ci_user_client_secret_name"
    } : {}, var.app_var_map.create_ext_dns_user ? {
    external_dns_credentials_client_id_name_key     = "external_dns_credentials_client_id_name"
    external_dns_credentials_client_secret_name_key = "external_dns_credentials_client_secret_name"
    cert_manager_credentials_client_id_name_key     = "cert_manager_credentials_client_id_name"
    cert_manager_credentials_client_secret_name_key = "cert_manager_credentials_client_secret_name"
  } : {})

  node_labels = [
    for key, value in merge(var.app_var_map.master_hosts, var.app_var_map.agent_hosts) : {
      node_name   = key
      node_labels = value.node_labels
    } if length(value.node_labels) > 0
  ]
  node_taints = [
    for key, value in merge(var.app_var_map.master_hosts, var.app_var_map.agent_hosts) : {
      node_name   = key
      node_taints = value.node_taints
    } if length(value.node_taints) > 0
  ]
}
