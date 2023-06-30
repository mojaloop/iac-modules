terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/config-params/k8s-store-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    properties_var_map = {}
    secrets_var_map    = {}
    secrets_key_map    = {}
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

include "root" {
  path = find_in_parent_folders()
}


inputs = {
  cluster_name       = local.CLUSTER_NAME
  gitlab_project_id  = local.GITLAB_CURRENT_PROJECT_ID
  kv_path            = local.KV_SECRET_PATH
  properties_var_map = dependency.k8s_deploy.outputs.properties_var_map
  secrets_var_map    = dependency.k8s_deploy.outputs.secrets_var_map
  secrets_key_map    = dependency.k8s_deploy.outputs.secrets_key_map
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )
  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("CLUSTER_NAME")
  GITLAB_SERVER_URL         = get_env("CI_SERVER_URL")
  GITLAB_CURRENT_PROJECT_ID = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_TOKEN              = get_env("GITLAB_CI_PAT")
  VAULT_SERVER_URL          = get_env("VAULT_SERVER_URL")
  ENV_VAULT_TOKEN           = get_env("ENV_VAULT_TOKEN")
  KV_SECRET_PATH            = get_env("KV_SECRET_PATH")
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
  token   = "${local.ENV_VAULT_TOKEN}"
}
provider "gitlab" {
  token = "${local.GITLAB_TOKEN}"
  base_url = "${local.GITLAB_SERVER_URL}"
}
EOF
}

