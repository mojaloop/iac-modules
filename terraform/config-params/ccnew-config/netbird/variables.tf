variable "dashboard_fqdn" {
  description = "fqdn for netbird dashboard"
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

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}
