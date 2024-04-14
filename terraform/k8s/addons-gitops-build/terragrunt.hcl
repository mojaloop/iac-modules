terraform {
  source = "git::https://github.com/${get_env("addons_github_org")}/${get_env("addons_github_repo")}.git//${get_env("addons_github_module_path")}?ref=${get_env("addons_github_module_tag")}"
}


include "root" {
  path = find_in_parent_folders()
}

dependency "gitops_build" {
  config_path  = "../gitops-build"
  mock_outputs = {
    mojaloop_sync_wave         = 0
    mojaloop_output_path       = ""
  }
}


inputs = {
  tags                                     = local.tags
  common_var_map                           = local.common_vars
  app_var_map                              = merge(local.pm4ml_vars, local.mojaloop_vars, local.vnext_vars)
  addons_vars                              = local.addons_vars
  output_dir                               = local.GITOPS_BUILD_OUTPUT_DIR
  gitlab_project_url                       = local.GITLAB_PROJECT_URL
  cluster_name                             = local.CLUSTER_NAME
  addons_sync_wave                         = (dependency.gitops_build.outputs.mojaloop_sync_wave - 1)
  mojaloop_app_output_path                 = dependency.gitops_build.outputs.mojaloop_output_path
}

locals {
  env_vars                      = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  tags                          = local.env_vars.tags
  gitlab_readonly_rbac_group    = get_env("GITLAB_READONLY_RBAC_GROUP")
  gitlab_admin_rbac_group       = get_env("GITLAB_ADMIN_RBAC_GROUP")
  common_vars                   = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}"))
  pm4ml_vars                    = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/pm4ml-vars.yaml")}"))
  mojaloop_vars                 = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-vars.yaml")}"))
  vnext_vars                    = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/vnext-vars.yaml")}"))
  addons_vars                   = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/addons-vars.yaml")}"))
  GITLAB_SERVER_URL             = get_env("GITLAB_SERVER_URL")
  GITOPS_BUILD_OUTPUT_DIR       = get_env("GITOPS_BUILD_OUTPUT_DIR")
  CLUSTER_NAME                  = get_env("cluster_name")
  CLUSTER_DOMAIN                = get_env("domain")
  GITLAB_PROJECT_URL            = get_env("GITLAB_PROJECT_URL")
  GITLAB_CURRENT_PROJECT_ID     = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_CURRENT_GROUP_NAME     = get_env("GITLAB_CURRENT_GROUP_NAME")
  GITLAB_API_URL                = get_env("GITLAB_API_URL")
  CLOUD_REGION                  = get_env("cloud_region")
  ENABLE_VAULT_OIDC             = get_env("ENABLE_VAULT_OIDC")
  ENABLE_GRAFANA_OIDC           = get_env("ENABLE_GRAFANA_OIDC")
  LETSENCRYPT_EMAIL             = get_env("letsencrypt_email")
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
