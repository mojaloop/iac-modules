variable "gitlab_fqdn" {
  description = "fqdn for gitlab"
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
  default     = "gitlab-admin"
}

variable "oidc_debug_log" {
  type    = bool
  default = false
}

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}

variable "oidc_secret_name" {
  type        = string
  description = "name of oidc secret for clientid/secret"
  default     = "gitlab-oidc-secret"
}