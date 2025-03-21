resource "vault_kv_secret_v2" "secrets_var_map" {
  for_each            = local.merged_secrets_key_map
  mount               = var.kv_path
  name                = "${var.cluster_name}/${each.value}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = local.merged_secrets_var_map[each.value]
    }
  )
}