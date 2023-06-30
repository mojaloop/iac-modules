resource "vault_mount" "kv_secret" {
  path                      = var.kv_path
  type                      = "kv-v2"
  options                   = { version = "2" }
  default_lease_ttl_seconds = "120"
}


resource "vault_kv_secret_v2" "secrets_var_map" {
  for_each            = var.secrets_key_map
  mount               = vault_mount.kv_secret.path
  name                = "${var.cluster_name}/${each.value}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.secrets_var_map[each.value]
    }
  )
}