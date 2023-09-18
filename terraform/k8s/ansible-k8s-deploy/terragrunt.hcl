terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/k8s-deploy?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    master_hosts                = {}
    agent_hosts                 = {}
    bastion_hosts               = {}
    bastion_hosts_var_maps      = {}
    agent_hosts_var_maps        = {}
    master_hosts_var_maps       = {}
    all_hosts_var_maps          = {}
    master_hosts_yaml_maps      = {}
    agent_hosts_yaml_maps       = {}
    bastion_hosts_yaml_maps     = {}
    test_harness_hosts          = {}
    test_harness_hosts_var_maps = {}
    bastion_ssh_key             = "key"
    bastion_os_username         = "null"
    bastion_public_ip           = "null"
    haproxy_server_fqdn         = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "k8s_store_config" {
  config_path  = "../k8s-store-config"
  skip_outputs = true
}

inputs = {
  master_hosts           = dependency.k8s_deploy.outputs.master_hosts
  agent_hosts            = dependency.k8s_deploy.outputs.agent_hosts
  bastion_hosts          = dependency.k8s_deploy.outputs.bastion_hosts
  bastion_hosts_var_maps = merge(dependency.k8s_deploy.outputs.bastion_hosts_var_maps, local.bastion_hosts_var_maps)
  agent_hosts_var_maps   = dependency.k8s_deploy.outputs.agent_hosts_var_maps
  master_hosts_var_maps = merge(dependency.k8s_deploy.outputs.master_hosts_var_maps, local.master_hosts_var_maps, {
    tenant_vault_server_url = "http://${dependency.k8s_deploy.outputs.haproxy_server_fqdn}:8200"
  })
  all_hosts_var_maps          = merge(dependency.k8s_deploy.outputs.all_hosts_var_maps, local.all_hosts_var_maps)
  bastion_hosts_yaml_maps     = merge(dependency.k8s_deploy.outputs.bastion_hosts_yaml_maps, local.bastion_hosts_yaml_maps)
  master_hosts_yaml_maps      = dependency.k8s_deploy.outputs.master_hosts_yaml_maps
  agent_hosts_yaml_maps       = dependency.k8s_deploy.outputs.agent_hosts_yaml_maps
  test_harness_hosts          = dependency.k8s_deploy.outputs.test_harness_hosts
  test_harness_hosts_var_maps = dependency.k8s_deploy.outputs.test_harness_hosts_var_maps
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
    root_app_path                = "${local.ARGO_CD_ROOT_APP_PATH}/app-yamls"
    external_secrets_version     = local.common_vars.external_secrets_version
    argocd_version               = local.common_vars.argocd_version
    argocd_lovely_plugin_version = local.common_vars.argocd_lovely_plugin_version
    repo_url                     = get_env("GITLAB_PROJECT_URL")
    gitlab_server_url            = get_env("CI_SERVER_URL")
    gitlab_project_id            = get_env("GITLAB_CURRENT_PROJECT_ID")
    repo_username                = get_env("GITLAB_USERNAME")
    repo_password                = get_env("GITLAB_CI_PAT")
    tenant_vault_token           = get_env("ENV_VAULT_TOKEN")
    netmaker_join_tokens         = yamlencode([get_env("NETMAKER_ENV_TOKEN")])
    cluster_name                 = get_env("CLUSTER_NAME")
  }
  bastion_hosts_yaml_maps = {
    netmaker_join_tokens = yamlencode([get_env("NETMAKER_OPS_TOKEN")])
  }
  bastion_hosts_var_maps = {
    netmaker_image_version = local.env_vars.netmaker_version
    nexus_fqdn             = get_env("NEXUS_FQDN")
    seaweedfs_fqdn         = get_env("SEAWEEDFS_FQDN")
    vault_fqdn             = get_env("VAULT_FQDN")
    netmaker_master_key    = get_env("METMAKER_MASTER_KEY")
    netmaker_api_host      = get_env("NETMAKER_HOST_NAME")
  }
  all_hosts_var_maps = {
    seaweedfs_s3_listening_port      = get_env("SEAWEEDFS_S3_LISTENING_PORT")
    nexus_docker_repo_listening_port = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
    vault_listening_port             = get_env("TENANT_VAULT_LISTENING_PORT")
  }
}

include "root" {
  path = find_in_parent_folders()
}
