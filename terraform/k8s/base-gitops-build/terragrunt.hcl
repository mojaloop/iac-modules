terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/gitops/k8s-cluster-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


include "root" {
  path = find_in_parent_folders()
}

dependency "k8s_store_config" {
  config_path  = "../k8s-store-config"
  skip_outputs = true
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    nat_public_ips                   = ""
    internal_load_balancer_dns       = ""
    external_load_balancer_dns       = ""
    private_subdomain                = ""
    public_subdomain                 = ""
    external_interop_switch_fqdn     = ""
    internal_interop_switch_fqdn     = ""
    target_group_internal_https_port = 0
    target_group_internal_http_port  = 0
    target_group_external_https_port = 0
    target_group_external_http_port  = 0
    properties_key_map = {
      longhorn_backups_bucket_name_key = "mock"
    }
    secrets_key_map = {
      external_dns_cred_id_key         = "mock"
      external_dns_cred_secret_key     = "mock"
      longhorn_backups_cred_id_key     = "mock"
      longhorn_backups_cred_secret_key = "mock"
    }
    haproxy_server_fqdn  = "null"
    private_network_cidr = ""
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tags                                     = local.tags
  nat_public_ips                           = dependency.k8s_deploy.outputs.nat_public_ips
  internal_load_balancer_dns               = dependency.k8s_deploy.outputs.internal_load_balancer_dns
  external_load_balancer_dns               = dependency.k8s_deploy.outputs.external_load_balancer_dns
  private_subdomain                        = dependency.k8s_deploy.outputs.private_subdomain
  public_subdomain                         = dependency.k8s_deploy.outputs.public_subdomain
  external_interop_switch_fqdn             = dependency.k8s_deploy.outputs.external_interop_switch_fqdn
  internal_interop_switch_fqdn             = dependency.k8s_deploy.outputs.internal_interop_switch_fqdn
  secrets_key_map                          = dependency.k8s_deploy.outputs.secrets_key_map
  properties_key_map                       = dependency.k8s_deploy.outputs.properties_key_map
  internal_ingress_https_port              = dependency.k8s_deploy.outputs.target_group_internal_https_port
  internal_ingress_http_port               = dependency.k8s_deploy.outputs.target_group_internal_http_port
  external_ingress_https_port              = dependency.k8s_deploy.outputs.target_group_external_https_port
  external_ingress_http_port               = dependency.k8s_deploy.outputs.target_group_external_http_port
  cert_manager_chart_version               = local.common_vars.cert_manager_chart_version
  consul_chart_version                     = local.common_vars.consul_chart_version
  longhorn_chart_version                   = local.common_vars.longhorn_chart_version
  external_dns_chart_version               = local.common_vars.external_dns_chart_version
  vault_chart_version                      = local.common_vars.vault_chart_version
  vault_config_operator_helm_chart_version = local.common_vars.vault_config_operator_helm_chart_version
  nginx_helm_chart_version                 = local.common_vars.nginx_helm_chart_version
  loki_chart_version                       = local.common_vars.loki_chart_version
  mojaloop_chart_version                   = local.common_vars.mojaloop_chart_version
  mcm_enabled                              = local.common_vars.mcm_enabled
  mcm_chart_version                        = local.common_vars.mcm_chart_version
  mojaloop_enabled                         = local.common_vars.mojaloop_enabled
  bulk_enabled                             = local.common_vars.bulk_enabled
  third_party_enabled                      = local.common_vars.third_party_enabled
  output_dir                               = local.GITOPS_BUILD_OUTPUT_DIR
  gitlab_project_url                       = local.GITLAB_PROJECT_URL
  cluster_name                             = local.CLUSTER_NAME
  stateful_resources_config_file           = find_in_parent_folders("common-stateful-resources.json")
  current_gitlab_project_id                = local.GITLAB_CURRENT_PROJECT_ID
  gitlab_group_name                        = local.GITLAB_CURRENT_GROUP_NAME
  gitlab_api_url                           = local.GITLAB_API_URL
  gitlab_server_url                        = local.GITLAB_SERVER_URL
  dns_cloud_region                         = local.CLOUD_REGION
  gitlab_readonly_group_name               = local.gitlab_readonly_rbac_group
  gitlab_admin_group_name                  = local.gitlab_admin_rbac_group
  enable_vault_oidc                        = local.ENABLE_VAULT_OIDC
  letsencrypt_email                        = local.LETSENCRYPT_EMAIL
  enable_grafana_oidc                      = local.ENABLE_GRAFANA_OIDC
  kv_path                                  = local.KV_SECRET_PATH
  transit_vault_key_name                   = local.TRANSIT_VAULT_UNSEAL_KEY_NAME
  transit_vault_url                        = "http://${dependency.k8s_deploy.outputs.haproxy_server_fqdn}:8200"
  private_network_cidr                     = dependency.k8s_deploy.outputs.private_network_cidr
}

locals {
  env_vars                      = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  tags                          = local.env_vars.tags
  gitlab_readonly_rbac_group    = local.env_vars.gitlab_readonly_rbac_group
  gitlab_admin_rbac_group       = local.env_vars.gitlab_admin_rbac_group
  common_vars                   = yamldecode(file("${find_in_parent_folders("common-vars.yaml")}"))
  GITLAB_SERVER_URL             = get_env("GITLAB_SERVER_URL")
  GITOPS_BUILD_OUTPUT_DIR       = get_env("GITOPS_BUILD_OUTPUT_DIR")
  CLUSTER_NAME                  = get_env("CLUSTER_NAME")
  CLUSTER_DOMAIN                = get_env("CLUSTER_DOMAIN")
  GITLAB_PROJECT_URL            = get_env("GITLAB_PROJECT_URL")
  GITLAB_CURRENT_PROJECT_ID     = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_CURRENT_GROUP_NAME     = get_env("GITLAB_CURRENT_GROUP_NAME")
  GITLAB_API_URL                = get_env("GITLAB_API_URL")
  CLOUD_REGION                  = get_env("CLOUD_REGION")
  ENABLE_VAULT_OIDC             = get_env("ENABLE_VAULT_OIDC")
  ENABLE_GRAFANA_OIDC           = get_env("ENABLE_GRAFANA_OIDC")
  LETSENCRYPT_EMAIL             = get_env("LETSENCRYPT_EMAIL")
  GITLAB_TOKEN                  = get_env("GITLAB_CI_PAT")
  ENV_VAULT_TOKEN               = get_env("ENV_VAULT_TOKEN")
  KV_SECRET_PATH                = get_env("KV_SECRET_PATH")
  VAULT_GITLAB_ROOT_TOKEN       = get_env("VAULT_GITLAB_ROOT_TOKEN")
  TRANSIT_VAULT_UNSEAL_KEY_NAME = get_env("TRANSIT_VAULT_UNSEAL_KEY_NAME")
  VAULT_SERVER_URL              = get_env("VAULT_SERVER_URL")
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
    vault = "${local.common_vars.vault_provider_version}"
  }
}
provider "vault" {
  address = "${local.VAULT_SERVER_URL}"
  token   = "${local.VAULT_GITLAB_ROOT_TOKEN}"
}
provider "gitlab" {
  token = "${local.GITLAB_TOKEN}"
  base_url = "${local.GITLAB_SERVER_URL}"
}
EOF
}
