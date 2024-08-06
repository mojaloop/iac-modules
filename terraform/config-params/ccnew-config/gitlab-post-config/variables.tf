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

variable "private_repo_user" {
  description = "repo user name for private iac repo"
  default     = "null"
}

variable "private_repo" {
  description = "repo location for private iac"
  default     = "null"
}

variable "private_repo_token" {
  description = "token for private iac repo"
  default     = "null"
  sensitive   = true
}

variable "environment_list" {
  description = "env repos to pre-create"
}
