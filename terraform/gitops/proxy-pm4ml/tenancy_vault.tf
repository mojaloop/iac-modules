resource "vault_kv_secret_backend_v2" "cas_required" {
  mount        = "/secret"
  cas_required = true
}

resource "vault_kv_secret_v2" "mcm_client_a" {
  for_each  = var.app_var_map
  mount     = vault_kv_secret_backend_v2.cas_required.mount
  name      = "${var.cluster_name}/${each.key}/mcm_client_secret_a"
  options   = { cas = 0 }
  data_json = jsonencode({ value = "dummy" })
}

resource "vault_kv_secret_v2" "mcm_client_b" {
  for_each  = var.app_var_map
  mount     = vault_kv_secret_backend_v2.cas_required.mount
  name      = "${var.cluster_name}/${each.key}/mcm_client_secret_b"
  options   = { cas = 0 }
  data_json = jsonencode({ value = "dummy" })
}
