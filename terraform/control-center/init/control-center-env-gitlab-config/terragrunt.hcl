terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/gitlab/environment-gitlab-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible_cc_netmaker_deploy" {
  config_path = "../ansible-cc-netmaker-deploy"
  mock_outputs = {
    netmaker_token_map = {}
    netmaker_control_network_name = ""
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
}
dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    gitlab_root_token      = "temporary-dummy-id"
    gitlab_server_hostname = "temporary-dummy-id"
    public_zone_name       = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
}
dependency "control_center_gitlab_config" {
  config_path = "../control-center-gitlab-config"
  mock_outputs = {
    iac_group_id = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
}

inputs = {
  env_map      = merge(local.env_map, 
    { for key in keys(local.env_map) : key => merge(local.env_map[key], {
      netmaker_ops_token = length(dependency.ansible_cc_netmaker_deploy.outputs.netmaker_token_map) > 0 ? dependency.ansible_cc_netmaker_deploy.outputs.netmaker_token_map["${dependency.ansible_cc_netmaker_deploy.outputs.netmaker_control_network_name}-ops"].netmaker_token : ""
      netmaker_k8s_token = length(dependency.ansible_cc_netmaker_deploy.outputs.netmaker_token_map) > 0 ? dependency.ansible_cc_netmaker_deploy.outputs.netmaker_token_map["${key}-k8s"].netmaker_token : ""
      })
    })
  iac_group_id = dependency.control_center_gitlab_config.outputs.iac_group_id
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