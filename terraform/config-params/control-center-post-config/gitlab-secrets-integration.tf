resource "vault_jwt_auth_backend" "gitlab_secrets" {
    description         = "Gitlab JWT for external secrets"
    path                = var.gitlab_runner_jwt_path
    jwks_url            = "https://${var.gitlab_hostname}/oauth/discovery/keys"
    bound_issuer        = "https://${var.gitlab_hostname}"
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
  role_name       = var.gitlab_runner_role_name
  token_policies  = [vault_policy.gitlab_ci_runner.name]
  bound_claims_type = "glob"
  bound_claims = {
    ref_protected = "true"
  }
  user_claim      = "user_email"
  role_type       = "jwt"
}