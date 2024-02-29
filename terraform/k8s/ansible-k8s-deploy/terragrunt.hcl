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
  master_hosts  = dependency.k8s_deploy.outputs.master_hosts
  agent_hosts   = dependency.k8s_deploy.outputs.agent_hosts
  bastion_hosts = dependency.k8s_deploy.outputs.bastion_hosts
  bastion_hosts_var_maps = merge(dependency.k8s_deploy.outputs.bastion_hosts_var_maps, local.bastion_hosts_var_maps, {
    tenant_vault_server_url = "http://${dependency.k8s_deploy.outputs.haproxy_server_fqdn}:8200"
  })
  agent_hosts_var_maps          = dependency.k8s_deploy.outputs.agent_hosts_var_maps
  master_hosts_var_maps         = dependency.k8s_deploy.outputs.master_hosts_var_maps
  all_hosts_var_maps            = merge(dependency.k8s_deploy.outputs.all_hosts_var_maps, local.all_hosts_var_maps, 
  {
    registry_mirror_fqdn        = dependency.k8s_deploy.outputs.haproxy_server_fqdn
  }, (local.K8S_CLUSTER_TYPE == "microk8s") ? {
    microk8s_dns_resolvers = try(dependency.k8s_deploy.outputs.all_hosts_var_maps.dns_resolver_ip, "")
  } : {})
  bastion_hosts_yaml_maps       = merge(dependency.k8s_deploy.outputs.bastion_hosts_yaml_maps, local.bastion_hosts_yaml_maps)
  master_hosts_yaml_maps        = dependency.k8s_deploy.outputs.master_hosts_yaml_maps
  agent_hosts_yaml_maps         = dependency.k8s_deploy.outputs.agent_hosts_yaml_maps
  test_harness_hosts            = dependency.k8s_deploy.outputs.test_harness_hosts
  test_harness_hosts_var_maps   = dependency.k8s_deploy.outputs.test_harness_hosts_var_maps
  ansible_bastion_key           = dependency.k8s_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username   = dependency.k8s_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip     = dependency.k8s_deploy.outputs.bastion_public_ip
  ansible_collection_tag        = local.env_map[local.CLUSTER_NAME].ansible_collection_tag
  ansible_base_output_dir       = local.ANSIBLE_BASE_OUTPUT_DIR
  ansible_playbook_name         = "argo${local.K8S_CLUSTER_TYPE}_cluster_deploy"
  ansible_destroy_playbook_name = "argo${local.K8S_CLUSTER_TYPE}_cluster_destroy"
  master_node_supports_traffic = (local.total_agent_count == 0) ? true : false
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
  common_vars = yamldecode(file("${find_in_parent_folders("common-vars.yaml")}"))
  env_map = { for val in local.env_vars.envs :
    val["env"] => {
      cloud_region                         = val["cloud_region"]
      k8s_cluster_type                     = val["k8s_cluster_type"]
      cloud_platform                       = val["cloud_platform"]
      domain                               = val["domain"]
      iac_terraform_modules_tag            = val["iac_terraform_modules_tag"]
      ansible_collection_tag               = val["ansible_collection_tag"]
      enable_vault_oauth_to_gitlab         = val["enable_vault_oauth_to_gitlab"]
      enable_grafana_oauth_to_gitlab       = val["enable_grafana_oauth_to_gitlab"]
      letsencrypt_email                    = val["letsencrypt_email"]
      dns_zone_force_destroy               = val["dns_zone_force_destroy"]
      longhorn_backup_object_store_destroy = val["longhorn_backup_object_store_destroy"]
      nodes                                = val["nodes"]
      enable_k6s_test_harness              = val["enable_k6s_test_harness"]
      k6s_docker_server_instance_type      = val["k6s_docker_server_instance_type"]
      vpc_cidr                             = val["vpc_cidr"]
    }
  }
  ANSIBLE_BASE_OUTPUT_DIR          = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  K8S_CLUSTER_TYPE                 = get_env("K8S_CLUSTER_TYPE")
  ARGO_CD_ROOT_APP_PATH            = get_env("ARGO_CD_ROOT_APP_PATH")
  CLUSTER_NAME                     = get_env("CLUSTER_NAME")
  NEXUS_DOCKER_REPO_LISTENING_PORT = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
  NEXUS_FQDN                       = get_env("NEXUS_FQDN")

  total_agent_count  = try(sum([for node in local.env_map[local.CLUSTER_NAME].nodes : node.node_count if !node.master]), 0)
  total_master_count = try(sum([for node in local.env_map[local.CLUSTER_NAME].nodes : node.node_count if node.master]), 0)

  bastion_hosts_yaml_maps = {
    netmaker_join_tokens = yamlencode([get_env("NETMAKER_OPS_TOKEN")])
  }
  bastion_hosts_var_maps = {
    netmaker_image_version       = local.env_vars.netmaker_version
    nexus_fqdn                   = get_env("NEXUS_FQDN")
    seaweedfs_fqdn               = get_env("SEAWEEDFS_FQDN")
    vault_fqdn                   = get_env("VAULT_FQDN")
    netmaker_master_key          = get_env("METMAKER_MASTER_KEY")
    netmaker_api_host            = get_env("NETMAKER_HOST_NAME")
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
    cluster_name                 = get_env("CLUSTER_NAME")
    netmaker_env_network_name    = get_env("CLUSTER_NAME")
    eks_aws_secret_access_key    = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_SECRET_ACCESS_KEY") : ""
    eks_aws_access_key_id        = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_ACCESS_KEY_ID") : ""
    eks_aws_region               = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("CLOUD_REGION") : ""
  }
  all_hosts_var_maps = {
    seaweedfs_s3_listening_port      = get_env("SEAWEEDFS_S3_LISTENING_PORT")
    nexus_docker_repo_listening_port = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
    nexus_fqdn                       = get_env("NEXUS_FQDN")
    vault_listening_port             = get_env("TENANT_VAULT_LISTENING_PORT")
    registry_mirror_port             = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
    enable_registry_mirror           = true
  }
}

include "root" {
  path = find_in_parent_folders()
}
