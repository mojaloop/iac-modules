skip = true

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "http" {
    address        = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}"
    lock_address   = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}/lock"
    unlock_address = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}/lock"
  }
}
EOF
}
generate "data_control" {
  path = "data_control.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
data "terraform_remote_state" "control" {
  backend = "http"
  config = {
    password    = "${local.TF_CONTROL_STATE_TOKEN}"
    username    = "${local.TF_CONTROL_STATE_USER}"
    address     = "${local.TF_CONTROL_STATE_ADDRESS}"
  }
}
locals {
  nexus_fqdn = data.terraform_remote_state.control.outputs.nexus_fqdn
  nexus_docker_repo_listening_port = data.terraform_remote_state.control.outputs.nexus_docker_repo_listening_port
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
  common_vars               = yamldecode(file("$CONFIG_PATH/common-vars.yaml"))
  TF_STATE_BASE_ADDRESS     = get_env("TF_STATE_BASE_ADDRESS")
  GITLAB_PROVIDER_TOKEN     = get_env("GITLAB_PROVIDER_TOKEN")
  GITLAB_PROVIDER_URL       = get_env("GITLAB_PROVIDER_URL")
  TF_CONTROL_STATE_TOKEN    = get_env("TF_CONTROL_STATE_TOKEN")
  TF_CONTROL_STATE_USER     = get_env("TF_CONTROL_STATE_USER")
  TF_CONTROL_STATE_ADDRESS  = get_env("TF_CONTROL_STATE_ADDRESS")
}
