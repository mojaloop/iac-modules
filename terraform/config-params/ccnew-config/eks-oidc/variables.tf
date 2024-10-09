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

variable "zitadel_admin_human_user_id" {
  description = "admin zitadel human user id"
}

variable "oidc_provider_group_claim_prefix" {
  type        = string
  description = "groups"
}

variable "cluster_name" {
    type        = string
    description = "Name of the EKS Cluster"
}

variable "identity_provider_config_name" {
    type        = string
    description = "The name of the identity provider config"
}

variable "kubernetes_oidc_issuer_url" {
    type        = string
    description = "Issuer URL for the OpenID Connect identity provider"
}

variable "kubernetes_oidc_groups_claim" {
    type        = string
    description = "The JWT claim that the provider will use to return groups"
}

variable "kubernetes_oidc_groups_prefix" {
    type        = string
    description = "A prefix that is prepended to group claims"
    default     = ""
}

variable "kubernetes_oidc_username_claim" {
    type        = string
    description = "The JWT claim that the provider will use as the username"
    default     = ""
}

variable "kubernetes_oidc_username_prefix" {
    type        = string
    description = "A prefix that is prepended to username claims"
    default     = ""
}