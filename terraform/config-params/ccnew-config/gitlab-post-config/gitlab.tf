resource "gitlab_group" "iac" {
  name                              = "iac"
  path                              = "iac"
  description                       = "iac group"
  require_two_factor_authentication = true
  two_factor_grace_period           = var.two_factor_grace_period
}

resource "gitlab_project" "bootstrap" {
  name                   = "bootstrap"
  namespace_id           = gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = true
}

resource "gitlab_group" "tenancy_internal" {
  name                              = "tenancy-internal"
  path                              = "tenancy-internal"
  description                       = "tenancy internal"
  require_two_factor_authentication = true
  two_factor_grace_period           = var.two_factor_grace_period
  visibility_level                  = "internal"
}

resource "gitlab_project" "tenancy_docs" {
  name                   = "tenancy-docs"
  namespace_id           = gitlab_group.tenancy_internal.id
  initialize_with_readme = true
  shared_runners_enabled = false
  visibility_level       = "internal"
  pages_access_level     = "enabled"
}

resource "gitlab_group_variable" "vault_auth_path" {
  group             = gitlab_group.iac.id
  key               = "VAULT_AUTH_PATH"
  value             = var.gitlab_runner_jwt_path
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "vault_auth_role" {
  group             = gitlab_group.iac.id
  key               = "VAULT_AUTH_ROLE"
  value             = var.gitlab_runner_role_name
  protected         = true
  masked            = false
  environment_scope = "*"
}

/*resource "gitlab_group_variable" "vault_fqdn" {
  group             = gitlab_group.iac.id
  key               = "VAULT_FQDN"
  value             = var.vault_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}*/

resource "gitlab_group_variable" "private_repo_user" {
  group             = gitlab_group.iac.id
  key               = "PRIVATE_REPO_USER"
  value             = var.private_repo_user
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "private_repo" {
  group             = gitlab_group.iac.id
  key               = "PRIVATE_REPO"
  value             = var.private_repo
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "private_repo_token_vault_path" {
  group             = gitlab_group.iac.id
  key               = "PRIVATE_REPO_TOKEN_PATH"
  value             = "${gitlab_project.bootstrap.name}/private-repo-token"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "vault_kv_secret_v2" "private_repo_token" {
  mount               = var.kv_path
  name                = "${gitlab_project.bootstrap.name}/private-repo-token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = var.private_repo_token
    }
  )
}

# ci token 
resource "vault_kv_secret_v2" "gitlab_ci_pat" {
  mount               = var.kv_path
  name                = "gitlab/gitlab_ci_pat"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = gitlab_group_access_token.gitlab_ci_pat.token
    }
  )
}

resource "gitlab_group_access_token" "gitlab_ci_pat" {
  group        = gitlab_group.iac.id
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