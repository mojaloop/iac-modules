terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/k8s-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    master_hosts           = {}
    agent_hosts            = {}
    bastion_hosts          = {}
    bastion_hosts_var_maps = {}
    agent_hosts_var_maps   = {}
    master_hosts_var_maps  = {}
    all_hosts_var_maps     = {}
    bastion_ssh_key        = "key"
    bastion_os_username    = "null"
    bastion_public_ip      = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
}


inputs = {
  master_hosts                = dependency.k8s_deploy.outputs.master_hosts
  agent_hosts                 = dependency.k8s_deploy.outputs.agent_hosts
  bastion_hosts               = dependency.k8s_deploy.outputs.bastion_hosts
  bastion_hosts_var_maps      = dependency.k8s_deploy.outputs.bastion_hosts_var_maps
  agent_hosts_var_maps        = dependency.k8s_deploy.outputs.agent_hosts_var_maps
  master_hosts_var_maps       = merge(dependency.k8s_deploy.outputs.master_hosts_var_maps, local.master_hosts_var_maps)
  all_hosts_var_maps          = dependency.k8s_deploy.outputs.all_hosts_var_maps
  ansible_bastion_key         = dependency.k8s_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username = dependency.k8s_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip   = dependency.k8s_deploy.outputs.bastion_public_ip
  ansible_collection_tag      = local.env_vars.ansible_collection_tag
  ansible_base_output_dir     = local.ANSIBLE_BASE_OUTPUT_DIR
  ansible_playbook_name       = "argo${local.K8S_CLUSTER_TYPE}_cluster_deploy"
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
  common_vars = yamldecode(file("${find_in_parent_folders("common-vars.yaml")}"))
  env_map = { for val in local.env_vars.envs :
  val["env"] => val }
  ANSIBLE_BASE_OUTPUT_DIR = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  K8S_CLUSTER_TYPE        = get_env("K8S_CLUSTER_TYPE")
  ARGO_CD_ROOT_APP_PATH   = get_env("ARGO_CD_ROOT_APP_PATH")
  master_hosts_var_maps = {
    root_app_path = "${local.ARGO_CD_ROOT_APP_PATH}/app-yamls"
    external_secrets_version = local.common_vars.external_secrets_version
    argocd_version = local.common_vars.argocd_version
    argocd_lovely_plugin_version = local.common_vars.argocd_lovely_plugin_version
  }
}

include "root" {
  path = find_in_parent_folders()
}
