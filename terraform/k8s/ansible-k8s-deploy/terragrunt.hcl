terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/k8s-deploy?ref=${get_env("iac_terraform_modules_tag")}"
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
  skip_outputs = local.skip_outputs
  mock_outputs_allowed_terraform_commands = local.skip_outputs ? ["init", "validate", "plan", "show", "apply"] : ["init", "validate", "plan", "show"]
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
    tenant_vault_server_url = "https://${local.vault_fqdn}"
  })
  agent_hosts_var_maps          = merge(dependency.k8s_deploy.outputs.agent_hosts_var_maps, local.agent_hosts_var_maps)
  master_hosts_var_maps         = merge(dependency.k8s_deploy.outputs.master_hosts_var_maps, local.master_hosts_var_maps)
  all_hosts_var_maps            = merge(dependency.k8s_deploy.outputs.all_hosts_var_maps, local.all_hosts_var_maps,
  {
    registry_mirror_fqdn        = local.NEXUS_FQDN
  }, (local.K8S_CLUSTER_TYPE == "microk8s") ? {
    microk8s_dns_resolvers = try(dependency.k8s_deploy.outputs.all_hosts_var_maps.dns_resolver_ip, "")
    microk8s_version       = try(local.common_vars.microk8s_version, "1.29/stable")
  } : {})
  bastion_hosts_yaml_maps       = merge(dependency.k8s_deploy.outputs.bastion_hosts_yaml_maps, local.bastion_hosts_yaml_maps)
  master_hosts_yaml_maps        = dependency.k8s_deploy.outputs.master_hosts_yaml_maps
  agent_hosts_yaml_maps         = dependency.k8s_deploy.outputs.agent_hosts_yaml_maps
  test_harness_hosts            = dependency.k8s_deploy.outputs.test_harness_hosts
  test_harness_hosts_var_maps   = dependency.k8s_deploy.outputs.test_harness_hosts_var_maps
  ansible_bastion_key           = dependency.k8s_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username   = dependency.k8s_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip     = dependency.k8s_deploy.outputs.bastion_public_ip
  ansible_collection_tag        = local.env_vars.ansible_collection_tag
  ansible_base_output_dir       = local.ANSIBLE_BASE_OUTPUT_DIR
  ansible_playbook_name         = "argo${local.K8S_CLUSTER_TYPE}_cluster_deploy"
  ansible_destroy_playbook_name = "argo${local.K8S_CLUSTER_TYPE}_cluster_destroy"
  master_node_supports_traffic             = (local.total_agent_count == 0) ? true : false
  managed_stateful_resources_config_file   = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-managed.yaml")
  platform_stateful_resources_config_file  = find_in_parent_folders("${get_env("CONFIG_PATH")}/platform-stateful-resources.yaml")
  current_gitlab_project_id                = local.GITLAB_CURRENT_PROJECT_ID

}

locals {
  skip_outputs = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
  env_vars = yamldecode(
  file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  common_vars = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}"))
  ANSIBLE_BASE_OUTPUT_DIR          = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  K8S_CLUSTER_TYPE                 = get_env("k8s_cluster_type")
  ARGO_CD_ROOT_APP_PATH            = get_env("ARGO_CD_ROOT_APP_PATH")
  CLUSTER_NAME                     = get_env("cluster_name")
  NEXUS_DOCKER_REPO_LISTENING_PORT = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
  NEXUS_FQDN                       = get_env("NEXUS_FQDN")
  GITLAB_CURRENT_PROJECT_ID        = get_env("GITLAB_CURRENT_PROJECT_ID")
  vault_fqdn                       = get_env("VAULT_FQDN")


  total_agent_count  = try(sum([for node in local.env_vars.nodes : node.node_count if !node.master]), 0)
  total_master_count = try(sum([for node in local.env_vars.nodes : node.node_count if node.master]), 0)

  bastion_hosts_yaml_maps = {
    #netmaker_join_tokens = yamlencode(concat([get_env("NETMAKER_OPS_TOKEN")], [get_env("NETMAKER_ENV_TOKEN")]))
  }
  agent_hosts_var_maps  = {
    netbird_version              = get_env("NETBIRD_VERSION")
    netbird_api_host             = get_env("NETBIRD_API_HOST")
    netbird_setup_key            = get_env("NETBIRD_K8S_SETUP_KEY")   
  }
  master_hosts_var_maps  = {
    netbird_version              = get_env("NETBIRD_VERSION")
    netbird_api_host             = get_env("NETBIRD_API_HOST")
    netbird_setup_key            = get_env("NETBIRD_K8S_SETUP_KEY")   
  }
  bastion_hosts_var_maps = {
    netbird_version              = get_env("NETBIRD_VERSION")
    netbird_api_host             = get_env("NETBIRD_API_HOST")
    netbird_setup_key            = get_env("NETBIRD_GW_SETUP_KEY")
    nexus_fqdn                   = get_env("NEXUS_FQDN")
    ceph_fqdn                    = get_env("CEPH_OBJECTSTORE_FQDN")
    vault_fqdn                   = get_env("VAULT_FQDN")
    root_app_path                = "${local.ARGO_CD_ROOT_APP_PATH}/app-yamls"
    external_secrets_version     = local.common_vars.external_secrets_version
    argocd_version               = local.common_vars.argocd_version
    argocd_lovely_plugin_version = local.common_vars.argocd_lovely_plugin_version
    repo_url                     = get_env("GITLAB_PROJECT_URL")
    gitlab_server_url            = get_env("CI_SERVER_URL")
    zitadel_server_url           = get_env("ZITADEL_FQDN")
    gitlab_project_id            = get_env("GITLAB_CURRENT_PROJECT_ID")
    repo_username                = get_env("GITLAB_USERNAME")
    repo_password                = get_env("GITLAB_CI_PAT")
    tenant_vault_token           = get_env("ENV_VAULT_TOKEN")
    cluster_name                 = get_env("cluster_name")
    netmaker_env_network_name    = get_env("cluster_name")
    cluster_domain               = "${get_env("cluster_name")}.${get_env("domain")}"
    argocd_domain                = "${get_env("argocd_oidc_domain")}.${get_env("domain")}"
    oidc_admin_group             = get_env("gitlab_admin_rbac_group")
    argocd_admin_rbac_group      = get_env("argocd_admin_rbac_group")
    argocd_readonly_rbac_group   = get_env("argocd_user_rbac_group")
    zitadel_project_id           = get_env("zitadel_project_id")
    eks_aws_secret_access_key    = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_SECRET_ACCESS_KEY") : ""
    eks_aws_access_key_id        = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_ACCESS_KEY_ID") : ""
    eks_aws_region               = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("cloud_region") : ""
  }
  all_hosts_var_maps = {
    ceph_listening_port              = get_env("CEPH_OBJECTSTORE_PORT")
    nexus_docker_repo_listening_port = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
    nexus_fqdn                       = get_env("NEXUS_FQDN")
    vault_listening_port             = get_env("TENANT_VAULT_LISTENING_PORT")
    registry_mirror_port             = get_env("NEXUS_DOCKER_REPO_LISTENING_PORT")
    enable_registry_mirror           = true
    kubernetes_oidc_enabled          = get_env("KUBERNETES_OIDC_ENABLED")
    kubernetes_oidc_issuer           = get_env("KUBERNETES_OIDC_ISSUER")
    kubernetes_oidc_client_id        = get_env("KUBERNETES_OIDC_CLIENT_ID")
    kubernetes_oidc_groups_claim     = get_env("KUBERNETES_OIDC_GROUPS_CLAIM")
    kubernetes_oidc_groups_prefix    = get_env("KUBERNETES_OIDC_GROUPS_PREFIX")
    kubernetes_oidc_username_prefix  = get_env("KUBERNETES_OIDC_USERNAME_PREFIX")
    kubernetes_oidc_username_claim   = get_env("KUBERNETES_OIDC_USERNAME_CLAIM")
    kubernetes_oidc_k8s_user_group   = get_env("KUBERNETES_OIDC_K8S_USER_GROUP")
    kubernetes_oidc_k8s_admin_group  = get_env("KUBERNETES_OIDC_K8S_ADMIN_GROUP")
  }
}

include "root" {
  path = find_in_parent_folders()
}

skip = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
