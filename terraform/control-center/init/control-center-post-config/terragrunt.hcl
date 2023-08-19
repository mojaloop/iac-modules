terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/config-params/control-center-post-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible_cc_post_deploy" {
  config_path = "../ansible-cc-post-deploy"
  mock_outputs = {
    vault_root_token              = "temporary-dummy-id"
    netmaker_token_map            = {
      for key in keys(local.env_map) : "${key}-k8s" => {
        netmaker_token = "tempid"
      }
    }
    netmaker_control_network_name = ""
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "deep_map_only"
}
dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    vault_fqdn             = "temporary-dummy-id"
    gitlab_root_token      = "temporary-dummy-id"
    gitlab_server_hostname = "temporary-dummy-id"
    public_zone_name       = "temporary-dummy-id"
    netmaker_hosts_var_maps = {
      netmaker_master_key = "test"
    }
    bastion_hosts_var_maps = {
      netmaker_host_name = "test"
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "deep_map_only"
}

dependency "control_center_pre_config" {
  config_path = "../control-center-pre-config"
  mock_outputs = {
    iac_group_id = "temporary-dummy-id"
    docker_hosts_var_maps = {
      vault_oidc_client_id     = "temporary-dummy-id"
      vault_oidc_client_secret = "temporary-dummy-id"
    }

  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  gitlab_admin_rbac_group       = local.env_vars.gitlab_admin_rbac_group
  gitlab_hostname               = dependency.control_center_deploy.outputs.gitlab_server_hostname
  vault_oauth_app_client_id     = dependency.control_center_pre_config.outputs.docker_hosts_var_maps["vault_oidc_client_id"]
  vault_oauth_app_client_secret = dependency.control_center_pre_config.outputs.docker_hosts_var_maps["vault_oidc_client_secret"]
  vault_fqdn                    = dependency.control_center_deploy.outputs.vault_fqdn
  env_map = merge(local.env_map,
    { for key in keys(local.env_map) : key => merge(local.env_map[key], {
      netmaker_ops_token = length(dependency.ansible_cc_post_deploy.outputs.netmaker_token_map) > 0 ? dependency.ansible_cc_post_deploy.outputs.netmaker_token_map["${dependency.ansible_cc_post_deploy.outputs.netmaker_control_network_name}-ops"].netmaker_token : ""
      netmaker_env_token = length(dependency.ansible_cc_post_deploy.outputs.netmaker_token_map) > 0 ? dependency.ansible_cc_post_deploy.outputs.netmaker_token_map["${key}-k8s"].netmaker_token : ""
      })
  })
  iac_group_id = dependency.control_center_pre_config.outputs.iac_group_id
  gitlab_root_token = dependency.control_center_deploy.outputs.gitlab_root_token
  vault_root_token = dependency.ansible_cc_post_deploy.outputs.vault_root_token
  netmaker_master_key = dependency.control_center_deploy.outputs.netmaker_hosts_var_maps["netmaker_master_key"]
  netmaker_host_name = dependency.control_center_deploy.outputs.bastion_hosts_var_maps["netmaker_api_host"]
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
      cloud_region                   = val["cloud_region"]
      k8s_cluster_type               = val["k8s_cluster_type"]
      cloud_platform                 = val["cloud_platform"]
      domain                         = val["domain"]
      iac_terraform_modules_tag      = val["iac_terraform_modules_tag"]
      enable_vault_oauth_to_gitlab   = val["enable_vault_oauth_to_gitlab"]
      enable_grafana_oauth_to_gitlab = val["enable_grafana_oauth_to_gitlab"]
      letsencrypt_email              = val["letsencrypt_email"]
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
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.common_vars.gitlab_provider_version}"
    }
    vault = "${local.common_vars.vault_provider_version}"
  }
}
provider "vault" {
  address = "https://${dependency.control_center_deploy.outputs.vault_fqdn}"
  token   = "${dependency.ansible_cc_post_deploy.outputs.vault_root_token}"
}
provider "gitlab" {
  token = "${dependency.control_center_deploy.outputs.gitlab_root_token}"
  base_url = "https://${dependency.control_center_deploy.outputs.gitlab_server_hostname}"
}
EOF
}
