resource "gitlab_group" "gitlab_admin_rbac_group" {
  name        = var.gitlab_admin_rbac_group
  path        = var.gitlab_admin_rbac_group
  description = "${var.gitlab_admin_rbac_group} group"
  require_two_factor_authentication = true
  two_factor_grace_period           = var.two_factor_grace_period
}

resource "gitlab_group" "gitlab_readonly_rbac_group" {
  name        = var.gitlab_readonly_rbac_group
  path        = var.gitlab_readonly_rbac_group
  description = "${var.gitlab_readonly_rbac_group} group"
  require_two_factor_authentication = true
  two_factor_grace_period           = var.two_factor_grace_period
}

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

resource "gitlab_project_variable" "iam_user_key_id" {
  project   = gitlab_project.bootstrap.id
  key       = "AWS_ACCESS_KEY_ID"
  value     = var.iac_user_key_id
  protected = true
  masked    = true
}

resource "gitlab_project_variable" "iam_user_key_secret" {
  project   = gitlab_project.bootstrap.id
  key       = "AWS_SECRET_ACCESS_KEY"
  value     = var.iac_user_key_secret
  protected = true
  masked    = true
}

resource "gitlab_project_variable" "iac_templates_tag" {
  project   = gitlab_project.bootstrap.id
  key       = "IAC_TEMPLATES_TAG"
  value     = var.iac_templates_tag
  protected = true
  masked    = false
}

resource "gitlab_project_variable" "iac_terraform_modules_tag" {
  project   = gitlab_project.bootstrap.id
  key       = "IAC_TERRAFORM_MODULES_TAG"
  value     = var.iac_terraform_modules_tag
  protected = true
  masked    = false
}

resource "gitlab_project_variable" "control_center_cloud_provider" {
  project   = gitlab_project.bootstrap.id
  key       = "CONTROL_CENTER_CLOUD_PROVIDER"
  value     = var.control_center_cloud_provider
  protected = true
  masked    = false
}

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

resource "gitlab_group_variable" "bootstrap_project_id" {
  group             = gitlab_group.iac.id
  key               = "BOOTSTRAP_PROJECT_ID"
  value             = gitlab_project.bootstrap.id
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "private_repo_token" {
  group             = gitlab_group.iac.id
  key               = "PRIVATE_REPO_TOKEN"
  value             = var.private_repo_token
  protected         = true
  masked            = true
  environment_scope = "*"
}

resource "gitlab_application" "netmaker_oidc" {
  count        = var.enable_netmaker_oidc ? 1 : 0
  confidential = true
  scopes       = ["profile", "email", "openid"]
  name         = "netmaker_oidc"
  redirect_url = var.netmaker_oidc_redirect_url
}

resource "gitlab_group_variable" "nexus_fqdn" {
  group             = gitlab_group.iac.id
  key               = "NEXUS_FQDN"
  value             = var.nexus_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "nexus_docker_repo_listening_port" {
  group             = gitlab_group.iac.id
  key               = "NEXUS_DOCKER_REPO_LISTENING_PORT"
  value             = var.nexus_docker_repo_listening_port
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "seaweedfs_fqdn" {
  group             = gitlab_group.iac.id
  key               = "SEAWEEDFS_FQDN"
  value             = var.seaweedfs_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "seaweedfs_s3_listening_port" {
  group             = gitlab_group.iac.id
  key               = "SEAWEEDFS_S3_LISTENING_PORT"
  value             = var.seaweedfs_s3_listening_port
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "vault_fqdn" {
  group             = gitlab_group.iac.id
  key               = "VAULT_FQDN"
  value             = var.vault_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "tenant_vault_listening_port" {
  group             = gitlab_group.iac.id
  key               = "TENANT_VAULT_LISTENING_PORT"
  value             = var.tenant_vault_listening_port
  protected         = true
  masked            = false
  environment_scope = "*"
}
resource "gitlab_application" "tenant_vault_oidc" {
  count     = var.enable_vault_oidc ? 1 : 0
  confidential = true
  scopes       = ["openid"]
  name         = "tenant_vault_oidc"
  redirect_url = "https://${var.vault_fqdn}/ui/vault/auth/oidc/oidc/callback"
}

locals {
  private_repo_docker_credentials = base64encode("${var.private_repo_user}:${var.private_repo_token}")
  docker_auth_config = jsonencode({
    "auths" = {
      "github.com" = {
        "auth" = local.private_repo_docker_credentials
      }
    }
  })
}