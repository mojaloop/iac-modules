terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/${get_env("MANAGED_SVC_CLOUD_PLATFORM")}/support-svcs/deploy-managed-svcs?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


include "root" {
  path = find_in_parent_folders()
}


inputs = {
  tags                         = local.tags
  deployment_name              = local.CLUSTER_NAME
  managed_services_config_file = find_in_parent_folders("stateful-resources.json")
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("CLUSTER_NAME")
  CLUSTER_DOMAIN            = get_env("CLUSTER_DOMAIN")
  GITLAB_PROJECT_URL        = get_env("GITLAB_PROJECT_URL")
  GITLAB_SERVER_URL         = get_env("CI_SERVER_URL")
  GITLAB_CURRENT_PROJECT_ID = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_TOKEN              = get_env("GITLAB_CI_PAT")
  GITLAB_USERNAME           = get_env("GITLAB_USERNAME")
  K8S_CLUSTER_TYPE          = get_env("K8S_CLUSTER_TYPE")
  CLOUD_REGION              = get_env("CLOUD_REGION")
  aws_provider_version      = ">= 5.0.0"
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    %{if get_env("MANAGED_SVC_CLOUD_PLATFORM") == "aws"}
    aws   = "${local.aws_provider_version}"
    %{endif}
  }
}
%{if get_env("MANAGED_SVC_CLOUD_PLATFORM") == "aws"}
provider "aws" {
  region = "${local.CLOUD_REGION}"
}
%{endif}
EOF
}
