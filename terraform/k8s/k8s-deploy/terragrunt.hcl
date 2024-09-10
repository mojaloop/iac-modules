terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/${get_env("cloud_platform")}/${get_env("k8s_cluster_module")}?ref=${get_env("iac_terraform_modules_tag")}"
}


include "root" {
  path = find_in_parent_folders()
}


inputs = {
  tags                                 = local.tags
  cluster_name                         = local.CLUSTER_NAME
  domain                               = local.CLUSTER_DOMAIN
  dns_zone_force_destroy               = local.env_vars.dns_zone_force_destroy
  longhorn_backup_object_store_destroy = local.env_vars.longhorn_backup_object_store_destroy
  node_pools                           = local.enabled_node_pools
  enable_k6s_test_harness              = local.env_vars.enable_k6s_test_harness
  k6s_docker_server_instance_type      = local.env_vars.k6s_docker_server_instance_type
  vpc_cidr                             = local.env_vars.vpc_cidr
  master_node_supports_traffic         = local.env_vars.master_node_supports_traffic
  kubeapi_port                         = (local.K8S_CLUSTER_TYPE == "microk8s") ? 16443 : 6443
  block_size                           = (local.K8S_CLUSTER_TYPE == "eks") ? 3 : 4
  dns_provider                         = local.env_vars.dns_provider
  app_var_map                          = (local.CLOUD_PLATFORM == "bare-metal") ? local.cloud_platform_vars : null
  # for eks managed service
  netbird_version                      = local.netbird_version
  netbird_api_host                     = local.netbird_api_host
  netbird_setup_key                    = local.netbird_setup_key
  
  identity_provider_config_name    = "Zitadel"
  kubernetes_oidc_enabled          = get_env("KUBERNETES_OIDC_ENABLED")
  kubernetes_oidc_issuer           = get_env("KUBERNETES_OIDC_ISSUER")
  kubernetes_oidc_client_id        = get_env("KUBERNETES_OIDC_CLIENT_ID")
  kubernetes_oidc_groups_claim     = get_env("KUBERNETES_OIDC_GROUPS_CLAIM")
  kubernetes_oidc_groups_prefix    = get_env("KUBERNETES_OIDC_GROUPS_PREFIX")
  kubernetes_oidc_username_prefix  = get_env("KUBERNETES_OIDC_USERNAME_PREFIX")
  kubernetes_oidc_username_claim   = get_env("KUBERNETES_OIDC_USERNAME_CLAIM")    
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/${get_env("cloud_platform")}-vars.yaml")}")
  )
  enabled_node_pools = {for node_key, node in local.env_vars.nodes : node_key => node  if node != null}
  total_agent_count = try(sum([for node in local.env_vars.nodes : node.node_count if !node.master]), 0)
  total_master_count = try(sum([for node in local.env_vars.nodes : node.node_count if node.master]), 0)
  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("cluster_name")
  CLUSTER_DOMAIN            = get_env("domain")
  GITLAB_PROJECT_URL        = get_env("GITLAB_PROJECT_URL")
  GITLAB_SERVER_URL         = get_env("CI_SERVER_URL")
  GITLAB_CURRENT_PROJECT_ID = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_TOKEN              = get_env("GITLAB_CI_PAT")
  GITLAB_USERNAME           = get_env("GITLAB_USERNAME")
  K8S_CLUSTER_TYPE          = get_env("k8s_cluster_type")
  CLOUD_REGION              = get_env("cloud_region")
  CLOUD_PLATFORM            = get_env("cloud_platform")
  netbird_version           = get_env("NETBIRD_VERSION")
  netbird_api_host          = get_env("NETBIRD_API_HOST")
  netbird_setup_key         = get_env("NETBIRD_K8S_SETUP_KEY")    
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {

  required_providers {
    %{if get_env("cloud_platform") == "aws"}
    aws   = "${local.cloud_platform_vars.aws_provider_version}"
    %{endif}
  }
}
%{if get_env("cloud_platform") == "aws"}
provider "aws" {
  region = "${local.CLOUD_REGION}"
}
%{endif}
EOF
}

skip = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
