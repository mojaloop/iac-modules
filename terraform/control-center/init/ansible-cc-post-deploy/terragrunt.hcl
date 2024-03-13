terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/control-center-post-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    bastion_hosts           = {}
    netmaker_hosts          = {}
    docker_hosts            = {}
    bastion_hosts_var_maps  = {}
    netmaker_hosts_var_maps = {}
    docker_hosts_var_maps   = {}
    all_hosts_var_maps      = {}
    gitlab_server_hostname  = "temporary-dummy-id"
    bastion_ssh_key         = "key"
    bastion_os_username     = "null"
    bastion_public_ip       = "null"
    gitlab_root_token       = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

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
  bastion_hosts          = dependency.control_center_deploy.outputs.bastion_hosts
  netmaker_hosts         = dependency.control_center_deploy.outputs.netmaker_hosts
  docker_hosts           = dependency.control_center_deploy.outputs.docker_hosts
  bastion_hosts_var_maps = dependency.control_center_deploy.outputs.bastion_hosts_var_maps
  netmaker_hosts_var_maps = merge(dependency.control_center_deploy.outputs.netmaker_hosts_var_maps,
  dependency.control_center_pre_config.outputs.netmaker_hosts_var_maps, {netmaker_acme_email = local.env_vars.letsencrypt_email})
  docker_hosts_var_maps = merge(dependency.control_center_deploy.outputs.docker_hosts_var_maps,
  dependency.control_center_pre_config.outputs.docker_hosts_var_maps, {dex_acme_email = local.env_vars.letsencrypt_email})
  all_hosts_var_maps          = dependency.control_center_deploy.outputs.all_hosts_var_maps
  enable_netmaker_oidc        = local.env_vars.enable_netmaker_oidc
  ansible_bastion_key         = dependency.control_center_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username = dependency.control_center_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip   = dependency.control_center_deploy.outputs.bastion_public_ip
  ansible_collection_tag      = local.env_vars.ansible_collection_tag
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
  token = "${dependency.control_center_deploy.outputs.gitlab_root_token}"
  base_url = "https://${dependency.control_center_deploy.outputs.gitlab_server_hostname}"
}
EOF
}
