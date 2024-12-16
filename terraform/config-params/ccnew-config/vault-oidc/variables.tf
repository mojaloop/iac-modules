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

variable "admin_policy_name" {
  description = "policy name for admins"
  default     = "vault-admin"
}

variable "oidc_provider_group_claim_prefix" {
  type        = string
  description = "groups"
}

variable "oidc_debug_log" {
  type    = bool
  default = false
}

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}
