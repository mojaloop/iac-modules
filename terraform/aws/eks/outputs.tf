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
  value = module.base_infra.public_int_zone.name
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
  value = var.target_group_internal_https_port
}
output "target_group_internal_http_port" {
  value = var.target_group_internal_http_port
}
output "target_group_external_https_port" {
  value = var.target_group_external_https_port
}
output "target_group_external_http_port" {
  value = var.target_group_external_http_port
}

output "target_group_internal_health_port" {
  value = var.target_group_internal_health_port
}
output "target_group_external_health_port" {
  value = var.target_group_external_health_port
}
output "target_group_vpn_port" {
  value = var.wireguard_port
}
output "private_network_cidr" {
  value = var.vpc_cidr
}

output "internal_k8s_network_cidr" {
  value = module.base_infra.private_subnets_cidr_blocks
}

output "ext_dns_cloud_policy" {
  value = module.post_config.ext_dns_cloud_policy
}

output "external_dns_cloud_role" {
  value = module.post_config.external_dns_cloud_role
}

output "object_storage_cloud_role" {
  value = module.post_config.object_storage_cloud_role
}
output "object_storage_bucket_name" {
  value = module.post_config.backup_bucket_name
}


###new items

output "bastion_ssh_key" {
  sensitive = true
  value     = module.base_infra.ssh_private_key
}

output "bastion_private_ip" {
  value = module.base_infra.bastion_private_ip
}
output "bastion_private_ips" {
  value = module.base_infra.bastion_private_ips
}
output "bastion_public_ip" {
  value = module.base_infra.bastion_public_ip
}
output "bastion_public_ips" {
  value = module.base_infra.bastion_public_ips
}
output "bastion_hosts" {
  value = zipmap([for i in range(length(module.base_infra.bastion_public_ips)) : "bastion${i + 1}"], module.base_infra.bastion_public_ips)
}
output "bastion_os_username" {
  value = var.os_user_name
}

output "dns_provider" {
  value = var.dns_provider
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
    ansible_ssh_user             = var.os_user_name
    ansible_ssh_retries          = "10"
    base_domain                  = local.base_domain
    internal_interop_switch_fqdn = "${var.int_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
    external_interop_switch_fqdn = "${var.ext_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
    kubeapi_loadbalancer_fqdn    = module.eks.cluster_endpoint
    eks_cluster_name             = module.eks.cluster_name
  }
}

output "agent_hosts_var_maps" {
  sensitive = false
  value     = {}
}

output "agent_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.vpc_cidr
  }
}

output "bastion_hosts_yaml_maps" {
  sensitive = false
  value = {
    eks_post_install_config_map = replace(module.eks.aws_auth_configmap_yaml, "{{", "{{ '{{' }}")
  }
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "ci_user_arn" {
  value = module.post_config.ci_user_arn
}

output "agent_hosts" {
  value = {}
}

output "master_hosts" {
  value = {}
}

output "test_harness_hosts" {
  value = var.enable_k6s_test_harness ? { test_harness = module.k6s_test_harness[0].test_harness_private_ip } : {}
}

output "test_harness_hosts_var_maps" {
  value = var.enable_k6s_test_harness ? module.k6s_test_harness[0].var_map : {}
}

output "private_subnets" {
  # value = "[${join(",", [for s in module.base_infra.private_subnets : format("'%s'", s)])}]"
  value = module.base_infra.private_subnets
}

output "vpc_id" {
  value = module.base_infra.vpc_id
}
