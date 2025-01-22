terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/${get_env("cloud_platform")}/${get_env("k8s_cluster_module")}?ref=${get_env("iac_terraform_modules_tag")}"
}


include "root" {
  path = find_in_parent_folders()
}


inputs = {
  tags                                 = local.tags
  cluster_name                         = local.CLUSTER_NAME
  domain                               = local.CLUSTER_DOMAIN
  dns_zone_force_destroy               = local.env_vars.dns_zone_force_destroy
  node_pools                           = local.enabled_node_pools
  vpc_cidr                             = local.env_vars.vpc_cidr
  master_node_supports_traffic         = local.env_vars.master_node_supports_traffic
  kubeapi_port                         = (local.K8S_CLUSTER_TYPE == "microk8s") ? 16443 : 6443
  block_size                           = (local.K8S_CLUSTER_TYPE == "eks") ? 3 : 4
  dns_provider                         = local.env_vars.dns_provider
  app_var_map                          = (local.CLOUD_PLATFORM == "bare-metal") ? local.cloud_platform_vars : null
  create_ext_dns_user                  = false
  create_ci_iam_user                   = true
  create_ext_dns_role                  = true
  create_csi_role                      = (local.K8S_CLUSTER_TYPE == "microk8s" && local.env_vars.enable_cloud_csi_provisioner) ? true : false
  iac_group_name                       = local.env_vars.iac_group_name
  backup_enabled                       = local.env_vars.enable_object_storage_backend
  backup_bucket_name                   = local.env_vars.object_storage_base_bucket_name
  eks_oidc_enabled                     = false
  backup_bucket_force_destroy          = local.env_vars.object_storage_force_destroy_bucket
  bastion_instance_size                = local.env_vars.bastion_instance_size
  coredns_bind_address                 = local.coredns_bind_address
  single_nat_gateway                   = try(local.env_vars.single_nat_gateway, true)
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/${get_env("cloud_platform")}-vars.yaml")}")
  )
  enabled_node_pools = {for node_key, node in local.env_vars.nodes : node_key => node  if node != null}
  total_agent_count = try(sum([for node in local.env_vars.nodes : node.node_count if !node.master]), 0)
  total_master_count = try(sum([for node in local.env_vars.nodes : node.node_count if node.master]), 0)
  tags                      = local.env_vars.tags
  CLUSTER_NAME              = get_env("cluster_name")
  CLUSTER_DOMAIN            = get_env("domain")
  K8S_CLUSTER_TYPE          = get_env("k8s_cluster_type")
  CLOUD_REGION              = get_env("cloud_region")
  CLOUD_PLATFORM            = get_env("cloud_platform")
  coredns_bind_address      = get_env("coredns_bind_address")  
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {

  required_providers {
    %{if get_env("cloud_platform") == "aws"}
    aws   = "${local.cloud_platform_vars.aws_provider_version}"
    %{endif}
  }
}
%{if get_env("cloud_platform") == "aws"}
provider "aws" {
  region = "${local.CLOUD_REGION}"
}
%{endif}
EOF
}
