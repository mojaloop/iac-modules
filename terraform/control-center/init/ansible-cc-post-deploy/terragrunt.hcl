terraform {
  source = "git::https://github.com/thitsax/mojaloop-iac-modules.git//terraform/ansible/control-center-post-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

# dependency "control_center_deploy" {
#   config_path = "../control-center-deploy"
#   mock_outputs = {
#     bastion_hosts           = {}
#     netmaker_hosts          = {}
#     docker_hosts            = {}
#     bastion_hosts_var_maps  = {}
#     netmaker_hosts_var_maps = {}
#     docker_hosts_var_maps   = {}
#     all_hosts_var_maps      = {}
#     gitlab_server_hostname  = "temporary-dummy-id"
#     bastion_ssh_key         = "key"
#     bastion_os_username     = "null"
#     bastion_public_ip       = "null"
#     gitlab_root_token       = "temporary-dummy-id"
#   }
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
#   mock_outputs_merge_strategy_with_state  = "shallow"
# }

dependency "control_center_pre_config" {
  config_path = "../control-center-pre-config"
  mock_outputs = {
    netmaker_hosts_var_maps = {}
    docker_hosts_var_maps = {
      gitlab_bootstrap_project_id = "temporary-dummy-id"
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  bastion_hosts          = local.env_vars.bastion_hosts
  netmaker_hosts         = local.env_vars.netmaker_hosts
  docker_hosts           = local.env_vars.docker_hosts
  bastion_hosts_var_maps = local.env_vars.bastion_hosts_var_maps
  netmaker_hosts_var_maps = merge(local.env_vars.netmaker_hosts_var_maps,
  dependency.control_center_pre_config.outputs.netmaker_hosts_var_maps)
  docker_hosts_var_maps = merge(local.env_vars.docker_hosts_var_maps,
  dependency.control_center_pre_config.outputs.docker_hosts_var_maps)
  all_hosts_var_maps          = local.env_vars.all_hosts_var_maps
  enable_netmaker_oidc        = local.env_vars.enable_netmaker_oidc
  ansible_bastion_key         = local.env_vars.bastion_ssh_key
  ansible_bastion_os_username = local.env_vars.bastion_os_username
  ansible_bastion_public_ip   = local.env_vars.bastion_public_ip
  ansible_collection_tag      = local.env_vars.ansible_collection_tag
  cc_netmaker_network_cidr    = local.env_vars.controlcenter_netmaker_network_cidr
  ansible_base_output_dir     = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  env_map                     = local.env_map
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )
  env_map = { for val in local.env_vars.envs :
  val["env"] => val }
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
  token = "${local.env_vars.gitlab_root_token}"
  base_url = "https://${local.env_vars.gitlab_server_hostname}"
}
EOF
}
