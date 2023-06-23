resource "vault_mount" "gitlab_secrets_jwt" {
  path        = "gitlab_secrets_jwt"
  type        = "jwt"
  description = "gitlab secrets jwt auth"
}

resource "vault_jwt_auth_backend" "gitlab_secrets" {
    description         = "Gitlab JWT for external secrets"
    path                = vault_mount.gitlab_secrets_jwt.path
    jwks_url            = "https://${var.gitlab_hostname}/-/jwks"
    bound_issuer        = var.gitlab_hostname
}

resource "vault_policy" "gitlab_ci_runner" {
  name     = "gitlab-ci-runner"

  policy = <<EOT
path "${vault_mount.kv_secret.path}/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_jwt_auth_backend_role" "gitlab_runner" {
  backend         = vault_jwt_auth_backend.gitlab_secrets.path
  role_name       = "gitlab-runner-role"
  token_policies  = [vault_policy.gitlab_ci_runner.name]
  bound_claims_type = "glob"
  bound_claims = {
    ref_protected = "true"
  }
  user_claim      = "user_email"
  role_type       = "jwt"
}