include "root" {
  path = find_in_parent_folders()
}

inputs = {
  outputDir     = get_env("GITOPS_BUILD_OUTPUT_DIR")
  clusterConfig = local.clusterConfig
  configPath    = get_env("CONFIG_PATH")
  gitlabUrl     = local.gitlabUrl
}

locals {
  skip_outputs  = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
  clusterConfig = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  commonVars    = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}", local.clusterConfig))
  vaultUrl      = get_env("VAULT_ADDR")
  vaultToken    = get_env("ENV_VAULT_TOKEN")
  gitlabUrl     = get_env("GITLAB_PROVIDER_URL")
  gitlabToken   = get_env("GITLAB_PROVIDER_TOKEN")
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {

  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.commonVars.gitlab_provider_version}"
    }
    vault = "${local.commonVars.vault_provider_version}"
  }
}
provider "vault" {
  address = "${local.vaultUrl}"
  token   = "${local.vaultToken}"
}
provider "gitlab" {
  base_url = "${local.gitlabUrl}"
  token = "${local.gitlabToken}"
}
EOF
}
