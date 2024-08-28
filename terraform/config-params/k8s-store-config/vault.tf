resource "vault_kv_secret_v2" "secrets_var_map" {
  for_each            = var.secrets_key_map
  mount               = var.kv_path
  name                = "${var.cluster_name}/${each.value}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = var.secrets_var_map[each.value]
    }
  )
}