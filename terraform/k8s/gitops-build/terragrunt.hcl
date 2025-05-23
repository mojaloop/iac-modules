terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/gitops/k8s-cluster-config?ref=${get_env("iac_terraform_modules_tag")}"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "k8s_store_config" {
  config_path  = "../k8s-store-config"
  skip_outputs = true
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    nat_public_ips                   = local.cloud_platform_vars.nat_public_ips
    internal_load_balancer_dns       = local.cloud_platform_vars.internal_load_balancer_dns
    external_load_balancer_dns       = local.cloud_platform_vars.external_load_balancer_dns
    private_subdomain                = local.cloud_platform_vars.private_subdomain
    public_subdomain                 = local.cloud_platform_vars.public_subdomain
    external_interop_switch_fqdn     = ""
    internal_interop_switch_fqdn     = ""
    target_group_internal_https_port = local.cloud_platform_vars.target_group_internal_https_port
    target_group_internal_http_port  = local.cloud_platform_vars.target_group_internal_http_port
    target_group_external_https_port = local.cloud_platform_vars.target_group_external_https_port
    target_group_external_http_port  = local.cloud_platform_vars.target_group_external_http_port
    properties_key_map = {
      external_dns_credentials_client_id_name_key     = "external_dns_credentials_client_id_name"
      external_dns_credentials_client_secret_name_key = "external_dns_credentials_client_secret_name"
      cert_manager_credentials_client_id_name_key     = "cert_manager_credentials_client_id_name"
      cert_manager_credentials_client_secret_name_key = "cert_manager_credentials_client_secret_name"
    }
    secrets_key_map = {
      external_dns_cred_id_key         = "route53_external_dns_access_key"
      external_dns_cred_secret_key     = "route53_external_dns_secret_key"
    }
    private_network_cidr = local.cloud_platform_vars.private_network_cidr
    dns_provider = "aws"
  }
  mock_outputs_allowed_terraform_commands = local.skip_outputs ? ["init", "validate", "plan", "show", "apply"] : ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tags                                     = local.tags
  nat_public_ips                           = dependency.k8s_deploy.outputs.nat_public_ips
  internal_load_balancer_dns               = dependency.k8s_deploy.outputs.internal_load_balancer_dns
  external_load_balancer_dns               = dependency.k8s_deploy.outputs.external_load_balancer_dns
  private_subdomain                        = dependency.k8s_deploy.outputs.private_subdomain
  public_subdomain                         = dependency.k8s_deploy.outputs.public_subdomain
  external_interop_switch_fqdn             = dependency.k8s_deploy.outputs.external_interop_switch_fqdn
  internal_interop_switch_fqdn             = dependency.k8s_deploy.outputs.internal_interop_switch_fqdn
  secrets_key_map                          = dependency.k8s_deploy.outputs.secrets_key_map
  properties_key_map                       = dependency.k8s_deploy.outputs.properties_key_map
  internal_ingress_https_port              = dependency.k8s_deploy.outputs.target_group_internal_https_port
  internal_ingress_http_port               = dependency.k8s_deploy.outputs.target_group_internal_http_port
  external_ingress_https_port              = dependency.k8s_deploy.outputs.target_group_external_https_port
  external_ingress_http_port               = dependency.k8s_deploy.outputs.target_group_external_http_port
  common_var_map                           = local.common_vars
  app_var_map                              = merge(local.pm4ml_vars, local.proxy_pm4ml_vars, local.mojaloop_vars, local.vnext_vars, local.cluster_vars)
  output_dir                               = local.GITOPS_BUILD_OUTPUT_DIR
  gitlab_project_url                       = local.GITLAB_PROJECT_URL
  cluster_name                             = local.CLUSTER_NAME
  stateful_resources_operators_config_file = find_in_parent_folders("${get_env("CONFIG_PATH")}/stateful-resources-operators.yaml")
  mojaloop_values_override_file            = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-values-override.yaml", "mojaloop-values-override.yaml")
  mcm_values_override_file                 = find_in_parent_folders("${get_env("CONFIG_PATH")}/mcm-values-override.yaml", "mcm-values-override.yaml")
  pm4ml_values_override_file               = find_in_parent_folders("${get_env("CONFIG_PATH")}/pm4ml-values-override.yaml", "pm4ml-values-override.yaml")
  proxy_values_override_file               = find_in_parent_folders("${get_env("CONFIG_PATH")}/proxy-values-override.yaml", "proxy-values-override.yaml")
  finance_portal_values_override_file      = find_in_parent_folders("${get_env("CONFIG_PATH")}/finance-portal-values-override.yaml", "finance-portal-values-override.yaml")
  mojaloop_stateful_res_helm_config_file   = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-local-helm.yaml")
  mojaloop_stateful_res_op_config_file     = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-local-operator.yaml")
  mojaloop_stateful_res_mangd_config_file  = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-managed.yaml")
  platform_stateful_resources_config_file  = find_in_parent_folders("${get_env("CONFIG_PATH")}/platform-stateful-resources.yaml")
  values_hub_provisioning_override_file    = find_in_parent_folders("${get_env("CONFIG_PATH")}/values-hub-provisioning-override.yaml", "values-hub-provisioning-override.yaml")
  mojaloop_stateful_res_monolith_config_file = find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-stateful-resources-managed-monolith.yaml")
  current_gitlab_project_id                = local.GITLAB_CURRENT_PROJECT_ID
  gitlab_group_name                        = local.GITLAB_CURRENT_GROUP_NAME
  gitlab_api_url                           = local.GITLAB_API_URL
  gitlab_server_url                        = local.GITLAB_SERVER_URL
  zitadel_server_url                       = local.zitadel_server_url
  dns_cloud_region                         = local.CLOUD_REGION
  gitlab_readonly_group_name               = local.gitlab_readonly_rbac_group
  gitlab_admin_group_name                  = local.gitlab_admin_rbac_group
  enable_vault_oidc                        = local.ENABLE_VAULT_OIDC
  letsencrypt_email                        = local.LETSENCRYPT_EMAIL
  enable_grafana_oidc                      = local.ENABLE_GRAFANA_OIDC
  kv_path                                  = local.KV_SECRET_PATH
  transit_vault_key_name                   = local.migrate ? local.mig_transit_vault_unseal_key_name : local.TRANSIT_VAULT_UNSEAL_KEY_NAME
  transit_vault_url                        = local.VAULT_SERVER_URL
  ceph_api_url                             = local.ceph_fqdn
  central_observability_endpoint           = local.central_observability_endpoint
  managed_db_host                          = ""      # to correct later
  private_network_cidr                     = dependency.k8s_deploy.outputs.private_network_cidr
  dns_provider                             = dependency.k8s_deploy.outputs.dns_provider
  rbac_api_resources_file                  = (local.common_vars.mojaloop_enabled || local.common_vars.vnext_enabled) ? find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-rbac-api-resources.yaml") : ""
  rbac_permissions_file                    = (local.common_vars.mojaloop_enabled || local.common_vars.vnext_enabled) ? find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-rbac-permissions.yaml") : find_in_parent_folders("${get_env("CONFIG_PATH")}/pm4ml-rbac-permissions.yaml")
  argocd_ingress_internal_lb               = local.argocd_ingress_internal_lb
  grafana_ingress_internal_lb              = local.grafana_ingress_internal_lb
  vault_ingress_internal_lb                = local.vault_ingress_internal_lb
  vault_admin_rbac_group                   = local.vault_admin_rbac_group
  vault_readonly_rbac_group                = local.vault_readonly_rbac_group
  gitlab_admin_rbac_group                  = local.gitlab_admin_rbac_group
  zitadel_project_id                       = local.zitadel_project_id
  grafana_admin_rbac_group                 = local.grafana_admin_rbac_group
  grafana_user_rbac_group                  = local.grafana_user_rbac_group
  managed_svc_as_monolith                  = local.managed_svc_as_monolith
}

locals {
  skip_outputs = get_env("CI_COMMIT_BRANCH") != get_env("CI_DEFAULT_BRANCH")
  clusterConfig                 = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  env_vars                      = merge(local.clusterConfig, {
    domainSuffix                = "${replace(local.clusterConfig.env,"/^.*(-[^-]+)$|^[^-]+([^-]{3})$/","$1$2")}.${local.clusterConfig.domain}"
  })
  tags                          = local.env_vars.tags
  gitlab_readonly_rbac_group    = get_env("GITLAB_READONLY_RBAC_GROUP")
  gitlab_admin_rbac_group       = get_env("GITLAB_ADMIN_RBAC_GROUP")
  grafana_admin_rbac_group      = get_env("grafana_admin_rbac_group")
  grafana_user_rbac_group       = get_env("grafana_user_rbac_group")
  vault_admin_rbac_group        = get_env("vault_admin_rbac_group")
  vault_readonly_rbac_group     = get_env("vault_user_rbac_group")
  zitadel_project_id            = get_env("zitadel_project_id")
  common_vars                   = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}", local.env_vars))
  pm4ml_vars                    = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/pm4ml-vars.yaml")}", local.env_vars))
  proxy_pm4ml_vars              = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/proxy-pm4ml-vars.yaml")}", local.env_vars))
  mojaloop_vars                 = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-vars.yaml")}", local.env_vars))
  vnext_vars                    = yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/vnext-vars.yaml")}", local.env_vars))

  cloud_platform_vars = merge({
    nat_public_ips                   = [""],
    internal_load_balancer_dns       = "",
    external_load_balancer_dns       = "",
    private_subdomain                = "int.${replace(get_env("cluster_name"), "-", "")}.${get_env("domain")}",
    public_subdomain                 = "${replace(get_env("cluster_name"), "-", "")}.${get_env("domain")}",
    target_group_internal_https_port = 31443,
    target_group_internal_http_port  = 31080,
    target_group_external_https_port = 32443,
    target_group_external_http_port  = 32080,
    private_network_cidr             = "${get_env("vpc_cidr")}"
  }, yamldecode(templatefile("${find_in_parent_folders("${get_env("CONFIG_PATH")}/${get_env("cloud_platform")}-vars.yaml")}", local.env_vars)))
  cluster_vars = {
    cluster = merge(local.env_vars, {
      master_node_count = get_env("cloud_platform") == "bare-metal" ? try(length(keys(local.cloud_platform_vars.master_hosts)), 0) : try(sum([for node in local.env_vars.nodes : node.node_count if node.master]), 0)
      agent_node_count  = get_env("cloud_platform") == "bare-metal" ? try(length(keys(local.cloud_platform_vars.agent_hosts)), 0) : try(sum([for node in local.env_vars.nodes : node.node_count if !node.master]), 0)
    })
  }
  GITLAB_SERVER_URL             = get_env("GITLAB_SERVER_URL")
  zitadel_server_url            = get_env("ZITADEL_FQDN")
  GITOPS_BUILD_OUTPUT_DIR       = get_env("GITOPS_BUILD_OUTPUT_DIR")
  CLUSTER_NAME                  = get_env("cluster_name")
  CLUSTER_DOMAIN                = get_env("domain")
  GITLAB_PROJECT_URL            = get_env("GITLAB_PROJECT_URL")
  GITLAB_CURRENT_PROJECT_ID     = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_CURRENT_GROUP_NAME     = get_env("GITLAB_CURRENT_GROUP_NAME")
  GITLAB_API_URL                = get_env("GITLAB_API_URL")
  CLOUD_REGION                  = get_env("cloud_region")
  ENABLE_VAULT_OIDC             = get_env("enable_vault_oidc")
  ENABLE_GRAFANA_OIDC           = get_env("enable_grafana_oidc")
  LETSENCRYPT_EMAIL             = get_env("letsencrypt_email")
  GITLAB_TOKEN                  = get_env("GITLAB_CI_PAT")
  ENV_VAULT_TOKEN               = get_env("ENV_VAULT_TOKEN")
  KV_SECRET_PATH                = get_env("KV_SECRET_PATH")
  VAULT_GITLAB_ROOT_TOKEN       = get_env("ENV_VAULT_TOKEN")
  TRANSIT_VAULT_UNSEAL_KEY_NAME = get_env("TRANSIT_VAULT_UNSEAL_KEY_NAME")
  mig_transit_vault_unseal_key_name = "${get_env("TRANSIT_VAULT_UNSEAL_KEY_NAME")}-migrated"
  VAULT_SERVER_URL              = get_env("VAULT_SERVER_URL")
  VAULT_ADDR                    = get_env("VAULT_ADDR")
  ceph_fqdn                     = get_env("CEPH_OBJECTSTORE_FQDN")
  central_observability_endpoint = get_env("MIMIR_GW_FQDN")
  migrate                       = get_env("migrate")
  argocd_ingress_internal_lb    = true
  grafana_ingress_internal_lb   = true
  vault_ingress_internal_lb     = true
  managed_svc_as_monolith       = get_env("managed_svc_as_monolith")
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {

  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.common_vars.gitlab_provider_version}"
    }
    vault = "${local.common_vars.vault_provider_version}"
  }
}
provider "vault" {
  address = "${local.VAULT_ADDR}"
  token   = "${local.VAULT_GITLAB_ROOT_TOKEN}"
}
provider "gitlab" {
  token = "${local.GITLAB_TOKEN}"
  base_url = "${local.GITLAB_SERVER_URL}"
}
EOF
}
