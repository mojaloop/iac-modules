
variable "iac_user_key_secret" {
  sensitive   = true
  description = "iam user key secret"
}

variable "iac_user_key_id" {
  description = "iam user keyid"
}

variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
}

variable "gitlab_readonly_rbac_group" {
  type        = string
  description = "rbac group in gitlab for readonly access via oidc"
}

variable "two_factor_grace_period" {
  description = "two_factor_grace_period in hours"
  default     = 0
}

variable "enable_netmaker_oidc" {
  type        = bool
  default     = true
  description = "enable oidc config of netmaker"
}

variable "netmaker_oidc_redirect_url" {
  description = "netmaker_oidc_redirect_url"
  default     = ""
}

variable "private_repo_user" {
  default = ""
}

variable "private_repo" {
  default = ""
}

variable "private_repo_token" {
  sensitive = true
  default   = ""
}

variable "iac_terraform_modules_tag" {
  description = "tag for repo for modules"
}
variable "iac_templates_tag" {
  description = "tag for repo for templates"
}
variable "control_center_cloud_provider" {
  description = "control_center_cloud_provider"
}

variable "minio_fqdn" {
  description = "minio_fqdn"
}
variable "minio_listening_port" {
  description = "minio_listening_port"
}

variable "nexus_fqdn" {
  description = "nexus_fqdn"
}
variable "nexus_docker_repo_listening_port" {
  description = "nexus_docker_repo_listening_port"
}

variable "vault_fqdn" {
  description = "vault_fqdn"
}
variable "tenant_vault_listening_port" {
  description = "tenant_vault_listening_port"
}

variable "enable_vault_oidc" {
  type        = bool
  default     = true
  description = "enable oidc config of tenancy vault"
}
