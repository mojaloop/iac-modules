variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
}
variable "gitlab_hostname" {
  description = "gitlab hostname for oidc"
}

variable "vault_oauth_app_client_id" {
  description = "client id for gitlab oidc"
  sensitive = true
}
variable "vault_oauth_app_client_secret" {
  description = "client secret for gitlab oidc"
  sensitive = true
}
variable "vault_fqdn" {
  description = "vault_fqdn"
}

variable "kv_path" {
  description = "path for kv engine"
  default = "secret"
}

variable "env_map" {
  type = map
  description = "env repos to pre-create"
}

variable "iac_group_id" {
  description = "group to add env projects to"
}

variable "gitlab_runner_role_name" {
  description = "role name for gitlab runner"
  default = "gitlab-runner-role"
}

variable "gitlab_runner_jwt_path" {
  default = "gitlab_secrets_jwt"
  description = "vault jwt path for gitlab runner"
}

variable "gitlab_ci_pat" {
  description = "pat for gitlab"
  sensitive = true
}