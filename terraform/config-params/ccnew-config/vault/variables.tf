variable "vault_fqdn" {
  description = "fqdn for vault ui"
  type        = string
}

variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
  type        = string
}

variable "admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
}

variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}
