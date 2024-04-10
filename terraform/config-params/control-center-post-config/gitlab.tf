
resource "gitlab_project" "envs" {
  for_each               = var.env_map
  name                   = each.key
  namespace_id           = var.iac_group_id
  initialize_with_readme = true
  shared_runners_enabled = true
}



resource "gitlab_project_variable" "domain" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "DOMAIN"
  value     = each.value["domain"]
  protected = false
  masked    = false
}

resource "gitlab_group_variable" "vault_auth_path" {
  group             = var.iac_group_id
  key               = "VAULT_AUTH_PATH"
  value             = var.gitlab_runner_jwt_path
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "vault_auth_role" {
  group             = var.iac_group_id
  key               = "VAULT_AUTH_ROLE"
  value             = var.gitlab_runner_role_name
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "vault_server_url" {
  group             = var.iac_group_id
  key               = "VAULT_SERVER_URL"
  value             = "https://$VAULT_FQDN"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kv_secret_path" {
  group             = var.iac_group_id
  key               = "KV_SECRET_PATH"
  value             = vault_mount.kv_secret.path
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "netmaker_host_name" {
  group             = var.iac_group_id
  key               = "NETMAKER_HOST_NAME"
  value             = var.netmaker_host_name
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "netmaker_version" {
  group             = var.iac_group_id
  key               = "NETMAKER_VERSION"
  value             = var.netmaker_version
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "gitlab_admin_rbac_group" {
  group             = var.iac_group_id
  key               = "GITLAB_ADMIN_RBAC_GROUP"
  value             = var.gitlab_admin_rbac_group
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "gitlab_readonly_rbac_group" {
  group             = var.iac_group_id
  key               = "GITLAB_READONLY_RBAC_GROUP"
  value             = var.gitlab_readonly_rbac_group
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "vault_kv_secret_v2" "netmaker_ops_token" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/netmaker_ops_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = each.value["netmaker_ops_token"]
    }
  )
}

resource "vault_kv_secret_v2" "netmaker_env_token" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/netmaker_env_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = each.value["netmaker_env_token"]
    }
  )
}

resource "vault_kv_secret_v2" "gitlab_root_token" {
  mount               = vault_mount.kv_secret.path
  name                = "bootstrap/gitlab_root_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.gitlab_root_token
    }
  )
}

resource "vault_kv_secret_v2" "vault_root_token" {
  mount               = vault_mount.kv_secret.path
  name                = "tenancy/vault_root_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.vault_root_token
    }
  )
}

resource "vault_kv_secret_v2" "netmaker_master_key" {
  mount               = vault_mount.kv_secret.path
  name                = "tenancy/netmaker_master_key"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.netmaker_master_key
    }
  )
}

resource "vault_kv_secret_v2" "gitlab_ci_pat" {
  mount               = vault_mount.kv_secret.path
  name                = "tenancy/gitlab_ci_pat"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_group_access_token.gitlab_ci_pat.token
    }
  )
}

resource "gitlab_group_access_token" "gitlab_ci_pat" {
  group        = var.iac_group_id
  name         = "gitlab ci pat"
  access_level = "owner"
  scopes       = ["api"]
  expires_at   = formatdate("YYYY-MM-DD", timeadd(timestamp(), "8736h"))
  lifecycle {
    ignore_changes = [
      expires_at,
    ]
  }
}

resource "vault_kv_secret_v2" "vault_oauth_client_id" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/vault_oauth_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.vault_oidc[each.key].application_id
    }
  )
}

resource "vault_kv_secret_v2" "vault_oauth_client_secret" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_vault_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/vault_oauth_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.vault_oidc[each.key].secret
    }
  )
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
  name         = "${each.key}_vault_oidc"
  redirect_url = "https://vault.${each.key}.${each.value["domain"]}/ui/vault/auth/oidc/oidc/callback"
}

resource "vault_kv_secret_v2" "grafana_oauth_client_id" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/grafana_oauth_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.grafana_oidc[each.key].application_id
    }
  )
}

resource "vault_kv_secret_v2" "grafana_oauth_client_secret" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_grafana_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/grafana_oauth_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.grafana_oidc[each.key].secret
    }
  )
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
  name         = "${each.key}_grafana_oidc"
  redirect_url = "https://grafana.${each.key}.${each.value["domain"]}/login/gitlab"
}

resource "vault_kv_secret_v2" "argocd_oauth_client_id" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_argocd_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/argocd_oauth_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.argocd_oidc[each.key].application_id
    }
  )
}

resource "vault_kv_secret_v2" "argocd_oauth_client_secret" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_argocd_oauth_to_gitlab
  }
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/argocd_oauth_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_application.argocd_oidc[each.key].secret
    }
  )
}

resource "gitlab_project_variable" "enable_argocd_oauth" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_argocd_oauth_to_gitlab
  }
  project   = gitlab_project.envs[each.key].id
  key       = "ENABLE_ARGOCD_OIDC"
  value     = "true"
  protected = false
  masked    = false
}

resource "gitlab_application" "argocd_oidc" {
  for_each = {
    for key, env in var.env_map : key => env if env.enable_argocd_oauth_to_gitlab
  }
  confidential = true
  scopes       = ["openid", "read_api", "profile", "email"]
  name         = "${each.key}_argocd_oidc"
  redirect_url = "https://argocd.${var.private_subdomain_string}.${each.key}.${each.value["domain"]}/auth/callback"
}
