terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/foundation-install?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


include "root" {
  path = find_in_parent_folders()
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    nat_public_ips                             = ""
    internal_load_balancer_dns                 = ""
    external_load_balancer_dns                 = ""
    private_subdomain                          = ""
    public_subdomain                           = ""
    longhorn_backups_bucket_name               = ""
    gitlab_key_route53_external_dns_access_key = ""
    gitlab_key_route53_external_dns_secret_key = ""
    gitlab_key_longhorn_backups_access_key     = ""
    gitlab_key_longhorn_backups_secret_key     = ""
    gitlab_key_vault_iam_user_access_key       = ""
    gitlab_key_vault_iam_user_secret_key       = ""
    vault_kms_seal_kms_key_id                  = ""
    target_group_internal_https_port           = 0
    target_group_internal_http_port            = 0
    target_group_external_https_port           = 0
    target_group_external_http_port            = 0

  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tags                                       = local.tags
  nat_public_ips                             = dependency.k8s_deploy.outputs.nat_public_ips
  internal_load_balancer_dns                 = dependency.k8s_deploy.outputs.internal_load_balancer_dns
  external_load_balancer_dns                 = dependency.k8s_deploy.outputs.external_load_balancer_dns
  private_subdomain                          = dependency.k8s_deploy.outputs.private_subdomain
  public_subdomain                           = dependency.k8s_deploy.outputs.public_subdomain
  longhorn_backups_bucket_name               = dependency.k8s_deploy.outputs.longhorn_backups_bucket_name
  gitlab_key_route53_external_dns_access_key = dependency.k8s_deploy.outputs.gitlab_key_route53_external_dns_access_key
  gitlab_key_route53_external_dns_secret_key = dependency.k8s_deploy.outputs.gitlab_key_route53_external_dns_secret_key
  gitlab_key_longhorn_backups_access_key     = dependency.k8s_deploy.outputs.gitlab_key_longhorn_backups_access_key
  gitlab_key_longhorn_backups_secret_key     = dependency.k8s_deploy.outputs.gitlab_key_longhorn_backups_secret_key
  gitlab_key_vault_iam_user_access_key       = dependency.k8s_deploy.outputs.gitlab_key_vault_iam_user_access_key
  gitlab_key_vault_iam_user_secret_key       = dependency.k8s_deploy.outputs.gitlab_key_vault_iam_user_secret_key
  vault_kms_seal_kms_key_id                  = dependency.k8s_deploy.outputs.vault_kms_seal_kms_key_id
  internal_ingress_https_port                = dependency.k8s_deploy.outputs.target_group_internal_https_port
  internal_ingress_http_port                 = dependency.k8s_deploy.outputs.target_group_internal_http_port
  external_ingress_https_port                = dependency.k8s_deploy.outputs.target_group_external_https_port
  external_ingress_http_port                 = dependency.k8s_deploy.outputs.target_group_external_http_port
  cert_manager_chart_version                 = local.common_vars.cert_manager_chart_version
  consul_chart_version                       = local.common_vars.consul_chart_version
  longhorn_chart_version                     = local.common_vars.longhorn_chart_version
  external_dns_chart_version                 = local.common_vars.external_dns_chart_version
  vault_chart_version                        = local.common_vars.vault_chart_version
  vault_config_operator_helm_chart_version   = local.common_vars.vault_config_operator_helm_chart_version
  nginx_helm_chart_version                   = local.common_vars.nginx_helm_chart_version
  loki_chart_version                         = local.common_vars.loki_chart_version
  output_dir                                 = local.FOUNDATION_BUILD_OUTPUT_DIR
  gitlab_project_url                         = local.GITLAB_PROJECT_URL
  cluster_name                               = local.CLUSTER_NAME
  stateful_resources_config_file             = find_in_parent_folders("stateful-resources.json")
  current_gitlab_project_id                  = local.GITLAB_CURRENT_PROJECT_ID
  gitlab_group_name                          = local.GITLAB_CURRENT_GROUP_NAME
  gitlab_api_url                             = local.GITLAB_API_URL
  gitlab_server_url                          = local.GITLAB_SERVER_URL
  gitlab_key_gitlab_ci_pat                   = local.GITLAB_KEY_GITLAB_CI_PAT
  dns_cloud_region                           = local.CLOUD_REGION
  gitlab_readonly_group_name                 = local.gitlab_readonly_rbac_group
  gitlab_admin_group_name                    = local.gitlab_admin_rbac_group
  enable_vault_oidc                          = local.ENABLE_VAULT_OIDC
  vault_oauth_client_secret                  = local.VAULT_OAUTH_CLIENT_SECRET
  vault_oauth_client_id                      = local.VAULT_OAUTH_CLIENT_ID
  letsencrypt_email                          = local.LETSENCRYPT_EMAIL
  enable_grafana_oidc                        = local.ENABLE_GRAFANA_OIDC
  grafana_oauth_client_secret                = local.GRAFANA_OAUTH_CLIENT_SECRET
  grafana_oauth_client_id                    = local.GRAFANA_OAUTH_CLIENT_ID
}

locals {
  env_vars                    = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  tags                        = local.env_vars.tags
  gitlab_readonly_rbac_group  = local.env_vars.gitlab_readonly_rbac_group
  gitlab_admin_rbac_group     = local.env_vars.gitlab_admin_rbac_group
  common_vars                 = yamldecode(file("${find_in_parent_folders("common-vars.yaml")}"))
  GITLAB_SERVER_URL           = get_env("GITLAB_SERVER_URL")
  FOUNDATION_BUILD_OUTPUT_DIR = get_env("FOUNDATION_BUILD_OUTPUT_DIR")
  CLUSTER_NAME                = get_env("CLUSTER_NAME")
  CLUSTER_DOMAIN              = get_env("CLUSTER_DOMAIN")
  GITLAB_PROJECT_URL          = get_env("GITLAB_PROJECT_URL")
  GITLAB_CURRENT_PROJECT_ID   = get_env("GITLAB_CURRENT_PROJECT_ID")
  GITLAB_CURRENT_GROUP_NAME   = get_env("GITLAB_CURRENT_GROUP_NAME")
  GITLAB_API_URL              = get_env("GITLAB_API_URL")
  GITLAB_KEY_GITLAB_CI_PAT    = get_env("GITLAB_KEY_GITLAB_CI_PAT")
  CLOUD_REGION                = get_env("CLOUD_REGION")
  ENABLE_VAULT_OIDC           = get_env("ENABLE_VAULT_OIDC")
  VAULT_OAUTH_CLIENT_SECRET   = get_env("ENABLE_VAULT_OIDC") ? get_env("VAULT_OAUTH_CLIENT_SECRET") : null
  VAULT_OAUTH_CLIENT_ID       = get_env("ENABLE_VAULT_OIDC") ? get_env("VAULT_OAUTH_CLIENT_ID") : null
  ENABLE_GRAFANA_OIDC         = get_env("ENABLE_GRAFANA_OIDC")
  GRAFANA_OAUTH_CLIENT_SECRET = get_env("ENABLE_GRAFANA_OIDC") ? get_env("GRAFANA_OAUTH_CLIENT_SECRET") : null
  GRAFANA_OAUTH_CLIENT_ID     = get_env("ENABLE_GRAFANA_OIDC") ? get_env("GRAFANA_OAUTH_CLIENT_ID") : null
  LETSENCRYPT_EMAIL           = get_env("LETSENCRYPT_EMAIL")
}
