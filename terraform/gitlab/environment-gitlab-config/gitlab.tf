
resource "gitlab_project" "envs" {
  for_each               = var.env_map
  name                   = each.key
  namespace_id           = var.iac_group_id
  initialize_with_readme = true
  shared_runners_enabled = true
}

resource "gitlab_project_variable" "k8s_cluster_type" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "K8S_CLUSTER_TYPE"
  value     = each.value["k8s_cluster_type"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "domain" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "DOMAIN"
  value     = each.value["domain"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "cloud_platform" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "CLOUD_PLATFORM"
  value     = each.value["cloud_platform"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "cloud_region" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "CLOUD_REGION"
  value     = each.value["cloud_region"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "letsencrypt_email" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "LETSENCRYPT_EMAIL"
  value     = each.value["letsencrypt_email"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "iac_terraform_modules_tag" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "IAC_TERRAFORM_MODULES_TAG"
  value     = each.value["iac_terraform_modules_tag"]
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "netmaker_ops_token" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "NETMAKER_OPS_TOKEN"
  value     = each.value["netmaker_ops_token"]
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "vault_oauth_client_id" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "VAULT_OAUTH_CLIENT_ID"
  value     = gitlab_application.vault_oidc[each.key].application_id
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "vault_oauth_client_secret" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "VAULT_OAUTH_CLIENT_SECRET"
  value     = gitlab_application.vault_oidc[each.key].secret
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "enable_vault_oidc" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "ENABLE_VAULT_OIDC"
  value     = "true"
  protected = false
  masked    = false
}

resource "gitlab_application" "vault_oidc" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  confidential = true
  scopes       = ["openid"]
  name         = "vault_oidc"
  redirect_url = "https://vault.${each.key}.${each.value["domain"]}/ui/vault/auth/oidc/oidc/callback"
}

resource "gitlab_project_variable" "grafana_oauth_client_id" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "GRAFANA_OAUTH_CLIENT_ID"
  value     = gitlab_application.grafana_oidc[each.key].application_id
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "grafana_oauth_client_secret" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "GRAFANA_OAUTH_CLIENT_SECRET"
  value     = gitlab_application.grafana_oidc[each.key].secret
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "enable_grafana_oauth" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "ENABLE_GRAFANA_OIDC"
  value     = "true"
  protected = false
  masked    = false
}

resource "gitlab_application" "grafana_oidc" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  confidential = true
  scopes       = ["read_api"]
  name         = "grafana_oidc"
  redirect_url = "https://grafana.${each.key}.${each.value["domain"]}/login/gitlab"
}