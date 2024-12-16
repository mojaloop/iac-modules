
variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}
variable "k8s_admin_auth_path" {
  description = "auth path for k8s engine for admin"
  default     = "kubernetes/admin"
}
variable "k8s_admin_role_name" {
  default     = "k8s-admin"
  description = "admin role hame for k8s engine secrets access"
}
variable "read_all_kv_secrets_policy_name" {
  default     = "read-all-kv-secrets"
  description = "policy name for reading all kv secrets"
}
variable "admin_policy_name" {
  description = "policy name for admins"
  default     = "vault-admin"
}
