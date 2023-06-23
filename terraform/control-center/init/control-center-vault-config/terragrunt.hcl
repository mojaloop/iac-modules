terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/vault/control-center-vault-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible_cc_post_deploy" {
  config_path  = "../ansible-cc-post-deploy"
  mock_outputs = {
    vault_root_token = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}
dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    vault_fqdn                       = "temporary-dummy-id"
    gitlab_server_hostname           = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "control_center_gitlab_config" {
  config_path = "../control-center-gitlab-config"
  mock_outputs = {
    docker_hosts_var_maps = {
      vault_oidc_client_id             = "temporary-dummy-id"
      vault_oidc_client_secret         = "temporary-dummy-id"
    }
    
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  gitlab_admin_rbac_group = local.env_vars.gitlab_admin_rbac_group
  gitlab_hostname = dependency.control_center_deploy.outputs.gitlab_server_hostname
  vault_oauth_app_client_id = dependency.control_center_gitlab_config.outputs.docker_hosts_var_maps["vault_oidc_client_id"]
  vault_oauth_app_client_secret = dependency.control_center_gitlab_config.outputs.docker_hosts_var_maps["vault_oidc_client_secret"]
  vault_fqdn = dependency.control_center_deploy.outputs.vault_fqdn
  env_map = local.env_map
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )
  env_map = { for val in local.env_vars.envs :
    val["env"] => {
      cloud_region            = val["cloud_region"]
      k8s_cluster_type          = val["k8s_cluster_type"]
      cloud_platform              = val["cloud_platform"]
      domain                    = val["domain"]
      iac_terraform_modules_tag = val["iac_terraform_modules_tag"]
      enable_vault_oauth_to_gitlab = val["enable_vault_oauth_to_gitlab"]
      enable_grafana_oauth_to_gitlab = val["enable_grafana_oauth_to_gitlab"]
      letsencrypt_email = val["letsencrypt_email"]
    }
  }
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
  token   = "${dependency.ansible_cc_post_deploy.outputs.vault_root_token}"
}
EOF
}
