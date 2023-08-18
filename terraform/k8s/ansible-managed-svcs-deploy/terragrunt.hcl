terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/managed-services-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "managed_services" {
  config_path = "../managed-services"
  mock_outputs = {
    bastion_hosts           = {}
    bastion_hosts_var_maps  = {}
    bastion_ssh_key         = "key"
    bastion_os_username     = "null"
    bastion_public_ip       = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}


inputs = {
  bastion_hosts               = dependency.managed_services.outputs.bastion_hosts
  bastion_hosts_var_maps      = merge(dependency.managed_services.outputs.bastion_hosts_var_maps, local.bastion_hosts_var_maps)
  bastion_hosts_yaml_maps     = local.bastion_hosts_yaml_maps
  ansible_bastion_key         = dependency.managed_services.outputs.bastion_ssh_key
  ansible_bastion_os_username = dependency.managed_services.outputs.bastion_os_username
  ansible_bastion_public_ip   = dependency.managed_services.outputs.bastion_public_ip
  ansible_collection_tag      = local.env_vars.ansible_collection_tag
  ansible_base_output_dir     = local.ANSIBLE_BASE_OUTPUT_DIR
  ansible_playbook_name       = "managed_services_deploy"
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
  common_vars = yamldecode(file("${find_in_parent_folders("common-vars.yaml")}"))
  env_map = { for val in local.env_vars.envs :
  val["env"] => val }
  ANSIBLE_BASE_OUTPUT_DIR = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  K8S_CLUSTER_TYPE        = get_env("K8S_CLUSTER_TYPE")

  bastion_hosts_yaml_maps = {
    netmaker_join_tokens = yamlencode([get_env("NETMAKER_OPS_TOKEN"), get_env("NETMAKER_ENV_TOKEN")])
  }
  bastion_hosts_var_maps = {
    netmaker_master_key = get_env("METMAKER_MASTER_KEY")
    netmaker_host_name  = get_env("VAULT_FQDN")
  }
}

include "root" {
  path = find_in_parent_folders()
}
