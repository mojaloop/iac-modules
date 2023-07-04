terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/${get_env("CLOUD_PLATFORM")}/base-k8s?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


include "root" {
  path = find_in_parent_folders()
}


inputs = {
  tags                                 = local.tags
  cluster_name                         = local.CLUSTER_NAME
  domain                               = local.CLUSTER_DOMAIN
  dns_zone_force_destroy               = true
  longhorn_backup_object_store_destroy = true
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CLOUD_PLATFORM")}-vars.yaml")}")
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
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    %{if get_env("CLOUD_PLATFORM") == "aws"}
    aws   = "${local.cloud_platform_vars.aws_provider_version}"
    %{endif}
  }
}
%{if get_env("CLOUD_PLATFORM") == "aws"}
provider "aws" {
  region = "${local.CLOUD_REGION}"
}
%{endif}
EOF
}
