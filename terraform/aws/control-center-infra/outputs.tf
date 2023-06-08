output "gitlab_root_password" {
  sensitive = true
  value     = random_password.gitlab_root_password.result
}

output "gitlab_root_token" {
  sensitive = true
  value     = random_password.gitlab_root_token.result
}

output "gitlab_s3_access_key" {
  sensitive = true
  value     = random_password.gitlab_s3_access_key.result
}

output "gitlab_s3_access_secret" {
  sensitive = true
  value     = random_password.gitlab_s3_access_secret.result
}

output "admin_s3_access_key" {
  sensitive = true
  value     = random_password.admin_s3_access_key.result
}

output "admin_s3_access_secret" {
  sensitive = true
  value     = random_password.admin_s3_access_secret.result
}

output "nexus_admin_password" {
  sensitive = true
  value     = random_password.nexus_admin_password.result
}

output "netmaker_oidc_callback_url" {
  value = var.enable_netmaker ? "https://${aws_route53_record.netmaker_api[0].name}/api/oauth/callback" : ""
}

output "gitlab_server_hostname" {
  value = aws_route53_record.gitlab_server_public.fqdn
}

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

output "nexus_docker_repo_listening_port" {
  value = var.nexus_docker_repo_listening_port
}

output "nexus_fqdn" {
  value = aws_route53_record.nexus_server_private.fqdn
}

output "seaweedfs_s3_listening_port" {
  value = var.seaweedfs_s3_listening_port
}

output "seaweedfs_fqdn" {
  value = aws_route53_record.seaweedfs_server_private.fqdn
}

output "gitlab_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_hostname        = aws_route53_record.gitlab_server_public.fqdn
    smtp_server_enable      = var.smtp_server_enable
    smtp_server_address     = var.smtp_server_address
    smtp_server_port        = var.smtp_server_port
    smtp_server_user        = var.smtp_server_user
    smtp_server_pw          = var.smtp_server_pw
    smtp_server_mail_domain = var.smtp_server_mail_domain
    enable_github_oauth     = var.enable_github_oauth
    github_oauth_id         = var.github_oauth_id
    github_oauth_secret     = var.github_oauth_secret
    letsencrypt_endpoint    = var.acme_api_endpoint
    server_password         = random_password.gitlab_root_password.result
    server_token            = random_password.gitlab_root_token.result
    server_hostname         = aws_route53_record.gitlab_server_public.fqdn
    enable_pages            = false
    gitlab_version          = var.gitlab_version
    s3_username             = random_password.gitlab_s3_access_key.result
    s3_password             = random_password.gitlab_s3_access_secret.result
    s3_server_url           = "http://${aws_route53_record.seaweedfs_server_private.fqdn}:${var.seaweedfs_s3_listening_port}"
    backup_ebs_volume_id    = aws_instance.gitlab_server.ebs_block_device.*.volume_id[0]
  }
}

output "all_hosts_var_maps" {
  value = {
    ansible_ssh_user       = var.os_user_name
    ansible_ssh_retries    = "10"
    base_domain            = local.base_domain
    gitlab_external_url    = "https://${aws_route53_record.gitlab_server_public.fqdn}"
    netmaker_image_version = var.netmaker_image_version
  }
}

output "docker_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_hostname                 = aws_route53_record.gitlab_runner_server_private.fqdn
    gitlab_server_hostname           = aws_route53_record.gitlab_server_public.fqdn
    gitlab_runner_version            = var.gitlab_runner_version
    seaweedfs_s3_server_host         = aws_route53_record.seaweedfs_server_private.fqdn
    seaweedfs_s3_listening_port      = var.seaweedfs_s3_listening_port
    seaweedfs_s3_admin_user          = "admin"
    seaweedfs_s3_admin_access_key    = random_password.admin_s3_access_key.result
    seaweedfs_s3_admin_secret_key    = random_password.admin_s3_access_secret.result
    seaweedfs_s3_gitlab_user         = "gitlab"
    seaweedfs_s3_gitlab_access_key   = random_password.gitlab_s3_access_key.result
    seaweedfs_s3_gitlab_secret_key   = random_password.gitlab_s3_access_secret.result
    nexus_admin_password             = random_password.nexus_admin_password.result
    nexus_docker_repo_listening_port = var.nexus_docker_repo_listening_port
    docker_extra_volume_name         = "docker-extra"
    docker_extra_vol_mount           = true
    docker_extra_ebs_volume_id       = aws_instance.docker_server.ebs_block_device.*.volume_id[0]
    docker_extra_volume_size_mb      = aws_instance.docker_server.ebs_block_device.*.volume_size[0] * 1074
    seaweedfs_num_volumes            = 100
    vault_root_token                 = random_password.vault_root_token.result
  }
}

output "netmaker_hosts_var_maps" {
  sensitive = true
  value = {
    netmaker_base_domain          = aws_route53_record.public_netmaker_ns[0].name
    netmaker_server_public_ip     = module.base_infra.netmaker_public_ip
    netmaker_master_key           = random_password.netmaker_master_key.result
    netmaker_mq_pw                = random_password.netmaker_mq_pw.result
    netmaker_admin_password       = random_password.netmaker_admin_password.result
    netmaker_oidc_issuer          = "https://${aws_route53_record.gitlab_server_public.fqdn}"
    netmaker_control_network_name = var.netmaker_control_network_name
    ansible_ssh_common_args       = "-o StrictHostKeyChecking=no"
  }
}

output "bastion_hosts_var_maps" {
  value = {
    netmaker_image_version  = var.netmaker_image_version
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
  }
}

output "bastion_hosts" {
  value = { bastion = module.base_infra.bastion_public_ip }
}

output "docker_hosts" {
  value = { docker = aws_instance.docker_server.private_ip }
}

output "gitlab_hosts" {
  value = { gitlab_server = aws_instance.gitlab_server.private_ip }
}

output "netmaker_hosts" {
  value = { netmaker_server = module.base_infra.netmaker_public_ip }
}

output "iac_user_key_id" {
  description = "key id for iac user for gitlab-ci"
  value       = aws_iam_access_key.gitlab_ci_iam_user_key.id
  sensitive   = false
}

output "iac_user_key_secret" {
  description = "key secret for iac user for gitlab-ci"
  value       = aws_iam_access_key.gitlab_ci_iam_user_key.secret
  sensitive   = true
}

output "public_zone_name" {
  value = module.base_infra.public_zone.name
}
