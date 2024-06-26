resource "vault_mount" "kv_secret" {
  path                      = var.kv_path
  type                      = "kv-v2"
  options                   = { version = "2" }
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
  deletion_allowed = true
}

resource "vault_policy" "env_transit" {
  for_each = var.env_map
  name     = "env-transit-${each.key}"

  policy = <<EOT
path "${vault_mount.kv_secret.path}/data/${each.key}/*" {
  capabilities = ["read", "list"]
}

path "${vault_mount.kv_secret.path}/data/tenancy/*" {
  capabilities = ["read", "list"]
}

path "${vault_mount.transit.path}/encrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}

path "${vault_mount.transit.path}/decrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}

path "auth/token/roles/${each.key}-auth-backend-role" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_token_auth_backend_role" "vault_token_auth_backend_role" {
  for_each               = var.env_map  
  role_name              = "${each.key}-auth-backend-role"
  token_period           = var.env_token_period
  token_explicit_max_ttl = var.env_token_explicit_max_ttl
  allowed_policies       = [vault_policy.env_transit[each.key].name]
}

resource "vault_token" "env_token" {
  for_each  = var.env_map
  policies  = [vault_policy.env_transit[each.key].name]
  no_parent = true
  role_name = vault_token_auth_backend_role.vault_token_auth_backend_role[each.key].role_name
}

resource "vault_kv_secret_v2" "env_token" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/env_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = vault_token.env_token[each.key].client_token
    }
  )
}

resource "gitlab_project_variable" "transit_vault_unseal_key_name" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "TRANSIT_VAULT_UNSEAL_KEY_NAME"
  value     = vault_transit_secret_backend_key.unseal_key[each.key].name
  protected = false
  masked    = false
}
