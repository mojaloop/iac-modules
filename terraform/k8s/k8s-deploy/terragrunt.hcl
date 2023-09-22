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
  dns_zone_force_destroy               = local.env_map[local.CLUSTER_NAME].dns_zone_force_destroy
  longhorn_backup_object_store_destroy = local.env_map[local.CLUSTER_NAME].longhorn_backup_object_store_destroy
  agent_instance_type                  = local.env_map[local.CLUSTER_NAME].agent_instance_type
  master_instance_type                 = local.env_map[local.CLUSTER_NAME].master_instance_type
  agent_node_count                     = local.env_map[local.CLUSTER_NAME].agent_node_count
  master_node_count                    = local.env_map[local.CLUSTER_NAME].master_node_count
  enable_k6s_test_harness              = local.env_map[local.CLUSTER_NAME].enable_k6s_test_harness
  k6s_docker_server_instance_type      = local.env_map[local.CLUSTER_NAME].k6s_docker_server_instance_type
  vpc_cidr                             = local.env_map[local.CLUSTER_NAME].vpc_cidr
  master_node_supports_traffic         = (local.env_map[local.CLUSTER_NAME].agent_node_count == 0) ? true : false
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CLOUD_PLATFORM")}-vars.yaml")}")
  )
  env_map = { for val in local.env_vars.envs :
    val["env"] => {
      cloud_region                         = val["cloud_region"]
      k8s_cluster_type                     = val["k8s_cluster_type"]
      cloud_platform                       = val["cloud_platform"]
      domain                               = val["domain"]
      iac_terraform_modules_tag            = val["iac_terraform_modules_tag"]
      ansible_collection_tag               = val["ansible_collection_tag"]
      enable_vault_oauth_to_gitlab         = val["enable_vault_oauth_to_gitlab"]
      enable_grafana_oauth_to_gitlab       = val["enable_grafana_oauth_to_gitlab"]
      letsencrypt_email                    = val["letsencrypt_email"]
      dns_zone_force_destroy               = val["dns_zone_force_destroy"]
      longhorn_backup_object_store_destroy = val["longhorn_backup_object_store_destroy"]
      agent_instance_type                  = val["agent_instance_type"]
      master_instance_type                 = val["master_instance_type"]
      master_node_count                    = val["master_node_count"]
      agent_node_count                     = val["agent_node_count"]
      enable_k6s_test_harness              = val["enable_k6s_test_harness"]
      k6s_docker_server_instance_type      = val["k6s_docker_server_instance_type"]
      vpc_cidr                             = val["vpc_cidr"]
    }
  }
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
