# Based on:
# # https://github.com/hashicorp/terraform-provider-vault/issues/1900
# resource "vault_kv_secret_backend_v2" "backend" {
#   mount        = "/secret"
# }

# Create dummy secrets so that deployment can proceed
resource "vault_kv_secret_v2" "mcm_client_a" {
  for_each     = var.app_var_map
  mount        = var.kv_path
  name         = "${var.cluster_name}/${each.key}/mcm_client_secret_a"
  data_json    = jsonencode({ value = "dummy" })
  disable_read = true
  lifecycle {
    ignore_changes  = [data_json]
  }
}

resource "vault_kv_secret_v2" "mcm_client_b" {
  for_each     = var.app_var_map
  mount        = var.kv_path
  name         = "${var.cluster_name}/${each.key}/mcm_client_secret_b"
  disable_read = true
  data_json    = jsonencode({ value = "dummy" })
  lifecycle {
    ignore_changes  = [data_json]
  }
}
