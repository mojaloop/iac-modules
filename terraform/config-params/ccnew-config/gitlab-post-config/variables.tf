variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
  default     = "tenant-admins"
}

variable "gitlab_readonly_rbac_group" {
  type        = string
  description = "rbac group in gitlab for readonly access via oidc"
  default     = "tenant-users"
}
variable "two_factor_grace_period" {
  description = "two_factor_grace_period in hours"
  default     = 0
}
