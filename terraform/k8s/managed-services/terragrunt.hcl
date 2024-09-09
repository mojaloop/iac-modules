terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/${get_env("managed_svc_cloud_platform")}/support-svcs/deploy-managed-svcs?ref=${get_env("iac_terraform_modules_tag")}"
}


include "root" {
  path = find_in_parent_folders()
}


inputs = {
  tags                         = local.tags
  deployment_name              = local.CLUSTER_NAME
  vpc_cidr                     = local.env_vars.managed_vpc_cidr


  managed_stateful_resources_config_file  = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-managed.yaml")
  platform_stateful_resources_config_file = find_in_parent_folders("${get_env("CONFIG_PATH")}/platform-stateful-resources.yaml")

  identity_provider_config_name    = "Zitadel"
  kubernetes_oidc_enabled          = get_env("KUBERNETES_OIDC_ENABLED")
  kubernetes_oidc_issuer           = get_env("KUBERNETES_OIDC_ISSUER")
  kubernetes_oidc_client_id        = get_env("KUBERNETES_OIDC_CLIENT_ID")
  kubernetes_oidc_groups_claim     = get_env("KUBERNETES_OIDC_GROUPS_CLAIM")
  kubernetes_oidc_groups_prefix    = get_env("KUBERNETES_OIDC_GROUPS_PREFIX")
  kubernetes_oidc_username_prefix  = get_env("KUBERNETES_OIDC_USERNAME_PREFIX")
  kubernetes_oidc_username_claim   = get_env("KUBERNETES_OIDC_USERNAME_CLAIM")  
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}")
  )
  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("cluster_name")
  CLUSTER_DOMAIN            = get_env("domain")
  GITLAB_PROJECT_URL        = get_env("GITLAB_PROJECT_URL")
  GITLAB_SERVER_URL         = get_env("CI_SERVER_URL")
  GITLAB_CURRENT_PROJECT_ID = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_TOKEN              = get_env("GITLAB_CI_PAT")
  GITLAB_USERNAME           = get_env("GITLAB_USERNAME")
  K8S_CLUSTER_TYPE          = get_env("k8s_cluster_type")
  CLOUD_REGION              = get_env("cloud_region")
  aws_provider_version      = ">= 5.0.0"  
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {

  required_providers {
    %{if get_env("managed_svc_cloud_platform") == "aws"}
    aws   = "${local.aws_provider_version}"
    %{endif}
  }
}
%{if get_env("managed_svc_cloud_platform") == "aws"}
provider "aws" {
  region = "${local.CLOUD_REGION}"
}
%{endif}
EOF
}

skip = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
