terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/gitlab/control-center-gitlab-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible-cc-deploy" {
  config_path  = "../ansible-cc-deploy"
  skip_outputs = true
}
dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    iac_user_key_secret              = "temporary-dummy-id"
    iac_user_key_id                  = "temporary-dummy-id"
    gitlab_root_token                = "temporary-dummy-id"
    gitlab_server_hostname           = "temporary-dummy-id"
    netmaker_oidc_callback_url       = "temporary-dummy-id"
    seaweedfs_s3_listening_port      = "temporary-dummy-id"
    nexus_docker_repo_listening_port = "temporary-dummy-id"
    seaweedfs_fqdn                   = "temporary-dummy-id"
    nexus_fqdn                       = "temporary-dummy-id"
    vault_listening_port             = "temporary-dummy-id"
    vault_fqdn                       = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  iac_user_key_secret              = dependency.control_center_deploy.outputs.iac_user_key_secret
  iac_user_key_id                  = dependency.control_center_deploy.outputs.iac_user_key_id
  gitlab_admin_rbac_group          = local.env_vars.gitlab_admin_rbac_group
  gitlab_readonly_rbac_group       = local.env_vars.gitlab_readonly_rbac_group
  enable_netmaker_oidc             = local.env_vars.enable_netmaker_oidc
  netmaker_oidc_redirect_url       = dependency.control_center_deploy.outputs.netmaker_oidc_callback_url
  seaweedfs_s3_listening_port      = dependency.control_center_deploy.outputs.seaweedfs_s3_listening_port
  nexus_docker_repo_listening_port = dependency.control_center_deploy.outputs.nexus_docker_repo_listening_port
  seaweedfs_fqdn                   = dependency.control_center_deploy.outputs.seaweedfs_fqdn
  nexus_fqdn                       = dependency.control_center_deploy.outputs.nexus_fqdn
  vault_listening_port             = dependency.control_center_deploy.outputs.vault_listening_port
  vault_fqdn                       = dependency.control_center_deploy.outputs.vault_fqdn
  private_repo_user                = get_env("PRIVATE_REPO_USER")
  private_repo_token               = get_env("PRIVATE_REPO_TOKEN")
  iac_templates_tag                = get_env("IAC_TEMPLATES_TAG")
  iac_terraform_modules_tag        = get_env("IAC_TERRAFORM_MODULES_TAG")
  control_center_cloud_provider    = get_env("CONTROL_CENTER_CLOUD_PROVIDER")
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )
}

include "root" {
  path = find_in_parent_folders()
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.common_vars.gitlab_provider_version}"
    }
  }
}
provider "gitlab" {
  token = "${dependency.control_center_deploy.outputs.gitlab_root_token}"
  base_url = "https://${dependency.control_center_deploy.outputs.gitlab_server_hostname}"
}
EOF
}
