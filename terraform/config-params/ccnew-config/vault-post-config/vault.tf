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

resource "vault_auth_backend" "kubernetes_admin" {
  type = "kubernetes"
  path = var.k8s_admin_auth_path
}

resource "vault_kubernetes_auth_backend_config" "local" {
  backend         = vault_auth_backend.kubernetes_admin.path
  kubernetes_host = "https://kubernetes.default.svc:443"
}

resource "vault_kubernetes_auth_backend_role" "k8s_admin" {
  backend                          = vault_auth_backend.kubernetes_admin.path
  role_name                        = var.k8s_admin_role_name
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["vault"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.vault_admin.name]
}

resource "vault_policy" "vault_admin" {
  name = "vault-admin"

  policy = <<EOT
path "/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}
resource "vault_policy" "read_all_kv_secrets" {
  name = var.read_all_kv_secrets_policy_name

  policy = <<EOT
path "${var.kv_path}/*" {
  capabilities = ["read", "list"]
}
EOT
}
