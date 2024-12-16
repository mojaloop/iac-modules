skip = true
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix    = "${replace(path_relative_to_include(), "/", "-")}-${get_env("cluster_name")}-state"
    config_path      = "${get_env("KUBECONFIG_LOCATION")}"
    namespace        = "${get_env("K8S_STATE_NAMESPACE")}"
  }
}
EOF
}

generate "gitlab_provider" {
  path = "gitlab_provider.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "gitlab" {
  token = "${local.GITLAB_PROVIDER_TOKEN}"
  base_url = "${local.GITLAB_PROVIDER_URL}"
}
 
EOF
}

generate "required_providers" {
  path = "required_providers.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "${local.common_vars.local_provider_version}"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.common_vars.gitlab_provider_version}"
    }
  }
}

EOF
}

locals {
  common_vars               = yamldecode(file("${get_env("CONFIG_PATH")}/common-vars.yaml"))
  GITLAB_PROVIDER_TOKEN     = get_env("GITLAB_PROVIDER_TOKEN")
  GITLAB_PROVIDER_URL       = get_env("GITLAB_PROVIDER_URL")
}
