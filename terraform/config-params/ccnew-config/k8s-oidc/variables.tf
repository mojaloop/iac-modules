variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
  type        = string
}

variable "admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
}

variable "user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
}

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}

variable "oidc_provider_group_claim_prefix" {
  type        = string
  description = "groups"
}
