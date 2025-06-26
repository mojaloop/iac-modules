include "root" {
  path = find_in_parent_folders()
}

inputs = {
  outputDir                = get_env("GITOPS_BUILD_OUTPUT_DIR")
  configPath               = find_in_parent_folders(get_env("CONFIG_PATH"))
  clusterConfig            = merge({
    domainSuffix           = "${replace(local.clusterConfig.env,"/^.*(-[^-]+)$|^[^-]+([^-]{3})$/","$1$2")}.${local.clusterConfig.domain}"
  }, local.clusterConfig, {
    gitlabUrl              = get_env("GITLAB_PROVIDER_URL")
    gitlabProjectUrl       = get_env("GITLAB_PROJECT_URL")
    gitlabProjectId        = get_env("GITLAB_CURRENT_PROJECT_ID")
    submoduleRevisions     = jsonencode(merge(try(jsondecode(get_env("SUBMODULE_REVISIONS")), {}), {
      iac_terraform_modules_tag = local.clusterConfig.iac_terraform_modules_tag,
      ansible_collection_tag  = local.clusterConfig.ansible_collection_tag
    }))
    gitlabProjectApi       = "${get_env("GITLAB_API_URL")}/projects/${get_env("GITLAB_CURRENT_PROJECT_ID")}"
  })
}

locals {
  skip_outputs  = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
  clusterConfig = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  commonVars    = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}", local.clusterConfig))
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
  address = "${get_env("VAULT_ADDR")}"
  token   = "${get_env("ENV_VAULT_TOKEN")}"
}
provider "gitlab" {
  base_url = "${get_env("GITLAB_PROVIDER_URL")}"
  token = "${get_env("GITLAB_PROVIDER_TOKEN")}"
}
EOF
}
