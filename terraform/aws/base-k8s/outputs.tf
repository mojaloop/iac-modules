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

output "longhorn_backups_bucket_name" {
  value = module.post_config.longhorn_backups_bucket_name
}

output "gitlab_key_route53_external_dns_access_key" {
  value = module.post_config.gitlab_key_route53_external_dns_access_key
}

output "gitlab_key_route53_external_dns_secret_key" {
  value = module.post_config.gitlab_key_route53_external_dns_secret_key
}

output "gitlab_key_longhorn_backups_access_key" {
  value = module.post_config.gitlab_key_longhorn_backups_access_key
}

output "gitlab_key_longhorn_backups_secret_key" {
  value = module.post_config.gitlab_key_longhorn_backups_secret_key
}

output "gitlab_key_vault_iam_user_access_key" {
  value = module.post_config.gitlab_key_vault_iam_user_access_key
}

output "gitlab_key_vault_iam_user_secret_key" {
  value = module.post_config.gitlab_key_vault_iam_user_secret_key
}

output "vault_kms_seal_kms_key_id" {
  value = module.post_config.vault_kms_seal_kms_key_id
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


###new items

output "bastion_ssh_key" {
  sensitive = true
  value     = module.base_infra.ssh_private_key
}

output "bastion_public_ip" {
  value = module.base_infra.bastion_public_ip
}

output "bastion_os_username" {
  value = var.os_user_name
}

output "master_hosts_var_maps" {
  sensitive = true
  value = {
    repo_url          = var.gitlab_project_url
    gitlab_server_url = var.gitlab_server_url
    gitlab_project_id = var.current_gitlab_project_id
    repo_username     = var.gitlab_username
  repo_password = var.gitlab_token }
}

output "master_hosts_yaml_maps" {
  sensitive = true
  value = {
    netmaker_join_tokens = yamlencode([module.post_config.netmaker_ops_token])
  }
}

output "all_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_user                 = var.os_user_name
    ansible_ssh_retries              = "10"
    base_domain                      = local.base_domain
    netmaker_image_version           = var.netmaker_image_version
    haproxy_server_fqdn              = module.base_infra.haproxy_server_fqdn
    seaweedfs_s3_listening_port      = module.post_config.seaweedfs_s3_listening_port
    nexus_docker_repo_listening_port = module.post_config.nexus_docker_repo_listening_port
    vault_listening_port             = module.post_config.vault_listening_port
  }
}

output "agent_hosts_var_maps" {
  sensitive = true
  value = {
    master_ip = data.aws_instances.master.private_ips[0]
  }
}

output "agent_hosts_yaml_maps" {
  sensitive = true
  value = {
    netmaker_join_tokens = yamlencode([module.post_config.netmaker_ops_token])
  }
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    nexus_fqdn              = module.post_config.nexus_fqdn
    seaweedfs_fqdn          = module.post_config.seaweedfs_fqdn
    vault_fqdn              = module.post_config.vault_fqdn
  }
}

output "bastion_hosts_yaml_maps" {
  sensitive = true
  value = {
    netmaker_join_tokens = yamlencode([module.post_config.netmaker_ops_token])
  }
}

output "bastion_hosts" {
  value = { bastion = module.base_infra.bastion_public_ip }
}

output "agent_hosts" {
  value = { for i, id in data.aws_instances.agent[0].ids : id => data.aws_instances.agent[0].private_ips[i] }
}

output "master_hosts" {
  value = { for i, id in data.aws_instances.master.ids : id => data.aws_instances.master.private_ips[i] }
}
