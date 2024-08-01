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

variable "gitlab_runner_role_name" {
  description = "role name for gitlab runner"
  default     = "gitlab-runner-role"
}

variable "gitlab_runner_jwt_path" {
  default     = "gitlab_secrets_jwt"
  description = "vault jwt path for gitlab runner"
}

variable "gitlab_fqdn" {
  description = "gitlab fqdn for jwt config"
}

variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}

variable "vault_fqdn" {
  description = "fqdn for vault"
}
