resource "vault_jwt_auth_backend" "gitlab_oidc" {
  description        = "terraform oidc auth backend"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://${var.gitlab_hostname}"
  oidc_client_id     = var.vault_oauth_app_client_id
  oidc_client_secret = var.vault_oauth_app_client_secret
  bound_issuer       = "https://${var.gitlab_hostname}"
  default_role       = var.gitlab_admin_rbac_group
}

resource "vault_jwt_auth_backend_role" "techops_admin_oidc" {
  backend               = vault_jwt_auth_backend.gitlab_oidc.path
  role_name             = var.gitlab_admin_rbac_group
  token_policies        = [vault_policy.admin.name]
  bound_audiences       = [var.vault_oauth_app_client_id]
  oidc_scopes           = ["openid"]
  user_claim            = "sub"
  role_type             = "oidc"
  allowed_redirect_uris = ["https://${var.vault_fqdn}/ui/vault/auth/oidc/oidc/callback"]
  bound_claims = {
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

resource "vault_mount" "kv_secret" {
  path                      = var.kv_path
  type                      = "kv"
  options                   = { version = "1" }
  default_lease_ttl_seconds = "120"
}

resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "transit mount for cluster vault unsealing"
}

resource "vault_transit_secret_backend_key" "unseal_key" {
  for_each = var.env_map
  backend  = vault_mount.transit.path
  name     = "unseal-key-${each.key}"
}

resource "vault_policy" "env_transit" {
  for_each = var.env_map
  name     = "env-transit-${each.key}"

  policy = <<EOT
path "${vault_mount.kv_secret.path}/${each.key}/*" {
  capabilities = ["read", "list"]
}

path "${vault_mount.transit.path}/encrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}

path "${vault_mount.transit.path}/decrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}
EOT
}

resource "vault_token" "autounseal" {
  for_each  = var.env_map
  policies  = [vault_policy.env_transit[each.key].name]
  no_parent = true
}

resource "vault_kv_secret" "autounseal_token" {
  for_each = var.env_map
  path     = "${vault_mount.kv_secret.path}/${each.key}/unseal_token"
  data_json = jsonencode(
    {
      value = vault_token.autounseal[each.key].client_token
    }
  )
}
