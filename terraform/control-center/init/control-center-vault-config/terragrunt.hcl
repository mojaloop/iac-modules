terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/vault/control-center-vault-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible-cc-post-deploy" {
  config_path  = "../ansible-cc-post-deploy"
  skip_outputs = true
}
dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    vault_listening_port             = "temporary-dummy-id"
    vault_fqdn                       = "temporary-dummy-id"
    vault_root_token                 = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "control_center_gitlab_config" {
  config_path = "../control-center-gitlab-config"
  mock_outputs = {
    docker_hosts_var_maps = {
      vault_oauth_app_client_id             = "temporary-dummy-id"
      vault_oauth_app_client_secret         = "temporary-dummy-id"
    }
    
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  vault_token = dependency.control_center_deploy.outputs.vault_root_token
  gitlab_admin_rbac_group = local.env_vars.gitlab_admin_rbac_group
  gitlab_hostname = dependency.control_center_deploy.outputs.gitlab_server_hostname
  vault_oauth_app_client_id = dependency.control_center_gitlab_config.outputs.docker_hosts_var_maps["vault_oidc_client_id"]
  vault_oauth_app_client_secret = dependency.control_center_gitlab_config.outputs.docker_hosts_var_maps["vault_oidc_client_secret"]
  vault_fqdn = dependency.control_center_deploy.outputs.vault_fqdn
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
    vault = "${local.common_vars.vault_provider_version}"
  }
}
provider "vault" {
  address = "https://${dependency.control_center_deploy.outputs.vault_fqdn}"
  token   = ${dependency.control_center_deploy.outputs.vault_root_token}
}
EOF
}
