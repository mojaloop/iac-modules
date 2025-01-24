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

variable "enable_central_observability_grafana_oidc" {
  type        = bool
  default     = true
  description = "enable oidc config of central_observability_grafana"
}

variable "central_observability_grafana_oidc_redirect_url" {
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

variable "minio_fqdn" {
  description = "minio_fqdn"
}
variable "minio_listening_port" {
  description = "minio_listening_port"
}

variable "mimir_fqdn" {
  description = "central observability mimir fqdn"
}

variable "mimir_listening_port" {
  description = "central observability mimir listening port"
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