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
