resource "vault_jwt_auth_backend" "gitlab_oidc" {
  description         = "terraform oidc auth backend"
  path                = "oidc"
  type                = "oidc"
  oidc_discovery_url  = "https://${var.gitlab_hostname}"
  oidc_client_id      = var.vault_oauth_app_client_id
  oidc_client_secret  = var.vault_oauth_app_client_secret
  bound_issuer        = "https://${var.gitlab_hostname}"
  default_role        = vault_jwt_auth_backend_role.techops_admin_oidc.role_name
}

resource "vault_jwt_auth_backend_role" "techops_admin_oidc" {
  backend         = vault_jwt_auth_backend.gitlab_oidc.path
  role_name       = "techops-admin"
  token_policies  = [vault_policy.admin.name]
  bound_audiences = [var.vault_oauth_app_client_id]
  oidc_scopes     = ["openid"]
  user_claim            = "sub"
  role_type             = "oidc"
  allowed_redirect_uris = ["https://${var.vault_fqdn}/ui/vault/auth/oidc/oidc/callback"]
  bound_claims  = {
      groups = var.gitlab_admin_rbac_group
  }
}

resource "vault_policy" "admin" {
  name = "admin-policy"

  policy = <<EOT

path "/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

EOT
}
