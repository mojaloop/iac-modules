resource "vault_generic_secret" "secrets_var_map" {
  for_each            = var.secrets_key_map
  path                = "${vault_mount.kv_secret.path}/${var.cluster_name}/${each.value}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.secrets_var_map[each.value]
    }
  )
}