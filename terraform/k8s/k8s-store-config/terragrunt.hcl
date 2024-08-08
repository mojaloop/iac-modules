terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/config-params/k8s-store-config?ref=${get_env("iac_terraform_modules_tag")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    properties_var_map = {}
    secrets_var_map    = {}
    secrets_key_map    = {}
  }
  skip_outputs = local.skip_outputs
  mock_outputs_allowed_terraform_commands = local.skip_outputs ? ["init", "validate", "plan", "show", "apply"] : ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "managed_services" {
  enabled = get_env("managed_svc_enabled")
  config_path = "../managed-services"
  mock_outputs = {
    properties_var_map = {}
    secrets_var_map    = {}
    secrets_key_map    = {}
  }
  skip_outputs = local.skip_outputs
  mock_outputs_allowed_terraform_commands = local.skip_outputs ? ["init", "validate", "plan", "show", "apply"] : ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

include "root" {
  path = find_in_parent_folders()
}


inputs = {
  cluster_name       = local.CLUSTER_NAME
  gitlab_project_id  = local.GITLAB_CURRENT_PROJECT_ID
  kv_path            = local.KV_SECRET_PATH
  properties_var_map = merge(local.properties_var_map, dependency.k8s_deploy.outputs.properties_var_map, dependency.managed_services.outputs.properties_var_map)
  secrets_var_map    = merge({ for key, value in dependency.k8s_deploy.outputs.secrets_var_map: key => replace(value, "$${", "$$${") }, { for key, value in dependency.managed_services.outputs.secrets_var_map: key => replace(value, "$${", "$$${") })
  secrets_key_map    = merge(dependency.k8s_deploy.outputs.secrets_key_map, dependency.managed_services.outputs.secrets_key_map)
}

locals {
  skip_outputs = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}")
  )

  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("cluster_name")
  GITLAB_SERVER_URL         = get_env("CI_SERVER_URL")
  GITLAB_CURRENT_PROJECT_ID = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_TOKEN              = get_env("GITLAB_CI_PAT")
  VAULT_SERVER_URL          = get_env("VAULT_SERVER_URL")
  ENV_VAULT_TOKEN           = get_env("ENV_VAULT_TOKEN")
  KV_SECRET_PATH            = get_env("KV_SECRET_PATH")
  VAULT_GITLAB_ROOT_TOKEN   = get_env("ENV_VAULT_TOKEN")
#replacing env vars from old control center post config
  properties_var_map = {
    K8S_CLUSTER_TYPE = get_env("k8s_cluster_type")
    K8S_CLUSTER_MODULE = get_env("k8s_cluster_module")
    CLOUD_PLATFORM = get_env("cloud_platform")
    K8S_CLUSTER_TYPE = get_env("k8s_cluster_type")
    K8S_CLUSTER_MODULE = get_env("k8s_cluster_module")
    MANAGED_SVC_CLOUD_PLATFORM = get_env("managed_svc_cloud_platform")
    CLOUD_PLATFORM_CLIENT_SECRET_NAME = get_env("cloud_platform_client_secret_name")
    CLOUD_REGION = get_env("cloud_region")
    LETSENCRYPT_EMAIL = get_env("letsencrypt_email")
  }
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

skip = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
