output "k8s_admin_auth_path" {
  value = var.k8s_admin_auth_path
}

output "k8s_admin_role_name" {
  value = var.k8s_admin_role_name
}

output "read_all_kv_secrets_policy_name" {
  value = var.read_all_kv_secrets_policy_name
}

output "admin_policy_name" {
  value = vault_policy.vault_admin.name
}
