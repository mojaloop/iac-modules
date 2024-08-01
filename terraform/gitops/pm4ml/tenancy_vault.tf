# Based on:
# https://github.com/hashicorp/terraform-provider-vault/issues/1900
resource "vault_kv_secret_backend_v2" "backend" {
  mount        = "/secret"
}

# Create dummy secrets so that deployment can proceed
resource "vault_kv_secret_v2" "mcm_client" {
  for_each     = var.app_var_map
  mount        = vault_kv_secret_backend_v2.backend.mount
  name         = "${var.cluster_name}/${each.key}/mcmdev_client_secret"
  data_json    = jsonencode({ value = "dummy" })
  disable_read = true
  lifecycle {
    ignore_changes  = [data_json]
    prevent_destroy = true
  }
}
