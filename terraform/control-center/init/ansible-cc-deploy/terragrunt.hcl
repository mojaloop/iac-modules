terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/control-center-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "control_center_deploy" {
  config_path = "../control-center-deploy"
  mock_outputs = {
    gitlab_hosts           = {}
    docker_hosts           = {}
    bastion_hosts          = {}
    bastion_hosts_var_maps = {}
    docker_hosts_var_maps  = {}
    gitlab_hosts_var_maps  = {}
    all_hosts_var_maps     = {}
    bastion_ssh_key        = "key"
    bastion_os_username    = "null"
    bastion_public_ip      = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}


inputs = {
  gitlab_hosts                = dependency.control_center_deploy.outputs.gitlab_hosts
  docker_hosts                = dependency.control_center_deploy.outputs.docker_hosts
  bastion_hosts               = dependency.control_center_deploy.outputs.bastion_hosts
  bastion_hosts_var_maps      = dependency.control_center_deploy.outputs.bastion_hosts_var_maps
  docker_hosts_var_maps       = dependency.control_center_deploy.outputs.docker_hosts_var_maps
  gitlab_hosts_var_maps       = dependency.control_center_deploy.outputs.gitlab_hosts_var_maps
  all_hosts_var_maps          = dependency.control_center_deploy.outputs.all_hosts_var_maps
  ansible_bastion_key         = dependency.control_center_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username = dependency.control_center_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip   = dependency.control_center_deploy.outputs.bastion_public_ip
  ansible_collection_tag      = local.env_vars.ansible_collection_tag
  ansible_base_output_dir     = get_env("ANSIBLE_BASE_OUTPUT_DIR")
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
  env_map = { for val in local.env_vars.envs :
  val["env"] => val }
}

include "root" {
  path = find_in_parent_folders()
}
