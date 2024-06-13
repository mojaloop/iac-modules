terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/config-params/ccnew-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible_k8s_deploy" {
  config_path  = "../ansible-k8s-deploy"
  mock_outputs = {
    zitadel_local_location = "null"
  }
}
dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    public_subdomain = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  public_subdomain = dependency.k8s_deploy.outputs.public_subdomain
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/${get_env("cloud_platform")}-vars.yaml")}")
  )
  common_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}")
  )
}

include "root" {
  path = find_in_parent_folders()
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    zitadel = {
      source = "zitadel/zitadel"
      version = "${local.common_vars.zitadel_provider_version}"
    }
  }
}
provider "zitadel" {
  jwt_profile_file = "${dependency.ansible_k8s_deploy.outputs.zitadel_local_location}/zitadel-admin-sa.json"
  domain = "zitadel.${dependency.k8s_deploy.outputs.public_subdomain}"
}
EOF
}