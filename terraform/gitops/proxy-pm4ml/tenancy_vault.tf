# Based on:
# https://github.com/hashicorp/terraform-provider-vault/issues/1900
# https://github.com/hashicorp/terraform-provider-vault/issues/1727
resource "vault_kv_secret_backend_v2" "cas_required" {
  mount        = "/secret"
  cas_required = true
}

# Create dummy secrets so that deployment can proceed
resource "vault_kv_secret_v2" "mcm_client_a" {
  for_each     = var.app_var_map
  mount        = vault_kv_secret_backend_v2.cas_required.mount
  name         = "${var.cluster_name}/${each.key}/mcm_client_secret_a"
  options      = { cas = 0 }
  data_json    = jsonencode({ value = "dummy" })
  disable_read = true
  lifecycle {
    ignore_changes  = [data_json]
    prevent_destroy = true
  }
}

resource "vault_kv_secret_v2" "mcm_client_b" {
  for_each     = var.app_var_map
  mount        = vault_kv_secret_backend_v2.cas_required.mount
  name         = "${var.cluster_name}/${each.key}/mcm_client_secret_b"
  options      = { cas = 0 }
  disable_read = true
  data_json    = jsonencode({ value = "dummy" })
  lifecycle {
    ignore_changes  = [data_json]
    prevent_destroy = true
  }
}
