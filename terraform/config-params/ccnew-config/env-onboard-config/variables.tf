variable "grafana_fqdn" {
  description = "fqdn for grafana"
}

variable "env_name" {
  description = "name of environment"
}

variable "gitlab_namespace" {
  description = "gitlab_namespace"
}

variable "vault_fqdn" {
  description = "fqdn for vault"
}

variable "argocd_fqdn" {
  description = "fqdn for argocd"
}

variable "kv_path" {
  description = "key value secret path"
}

variable "netbird_user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via netbird"
}

variable "netbird_admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via netbird"
}

variable "grafana_admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
}

variable "grafana_user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
}

variable "vault_admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
}

variable "vault_user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
}

variable "argocd_admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
}

variable "argocd_user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
}

variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
}

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}
