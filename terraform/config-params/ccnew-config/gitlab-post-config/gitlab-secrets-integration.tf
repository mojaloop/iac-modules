resource "vault_jwt_auth_backend" "gitlab_secrets" {
  description        = "Gitlab JWT for external secrets"
  path               = var.gitlab_runner_jwt_path
  oidc_discovery_url = "https://${var.gitlab_fqdn}"
  bound_issuer       = "https://${var.gitlab_fqdn}"
}

resource "vault_policy" "gitlab_ci_runner" {
  name = "gitlab-ci-runner"

  policy = <<EOT
path "${var.kv_path}/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_jwt_auth_backend_role" "gitlab_runner" {
  backend           = vault_jwt_auth_backend.gitlab_secrets.path
  role_name         = var.gitlab_runner_role_name
  bound_audiences   = ["https://${var.vault_fqdn}"]
  token_policies    = [vault_policy.gitlab_ci_runner.name]
  bound_claims_type = "glob"
  bound_claims = {
    ref_protected = "true"
  }
  user_claim = "user_email"
  role_type  = "jwt"
}
