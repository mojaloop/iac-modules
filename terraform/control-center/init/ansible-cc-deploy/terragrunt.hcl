terraform {
  source = "git::https://github.com/thitsax/mojaloop-iac-modules.git//terraform/ansible/control-center-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

inputs = {
  gitlab_hosts                = local.env_vars.gitlab_hosts
  docker_hosts                = local.env_vars.docker_hosts
  bastion_hosts               = local.env_vars.bastion_hosts
  bastion_hosts_var_maps      = local.env_vars.bastion_hosts_var_maps
  docker_hosts_var_maps       = local.env_vars.docker_hosts_var_maps
  gitlab_hosts_var_maps       = local.env_vars.gitlab_hosts_var_maps
  all_hosts_var_maps          = local.env_vars.all_hosts_var_maps
  ansible_bastion_key         = file("${find_in_parent_folders("sshkey")}")
  ansible_bastion_os_username = local.env_vars.bastion_os_username
  ansible_bastion_public_ip   = local.env_vars.bastion_public_ip
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
