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

variable "user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
}

variable "maintainer_rbac_group" {
  type        = string
  description = "rbac group in idm for maintainer access via oidc"
}

variable "oidc_provider_group_claim_prefix" {
  type        = string
  description = "groups"
}

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}

variable "gitlab_namespace" {
  description = "gitlab namespace"
}

variable "oidc_secret_name" {
  type        = string
  description = "name of oidc secret for clientid/secret"
  default     = "gitlab-oidc-secret"
}

variable "gitlab_zitadel_project_name" {
  type        = string
  description = "zitadel project name for gitlab"
  default     = "gitlab"
}
