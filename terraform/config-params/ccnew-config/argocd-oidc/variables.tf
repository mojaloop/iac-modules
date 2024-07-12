variable "argocd_fqdn" {
  description = "fqdn for argocd"
  type        = string
}

variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
  type        = string
}

variable "admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via oidc"
  default     = "argocd_administrators"
}

variable "user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via oidc"
  default     = "argocd_users"
}

variable "argocd_namespace" {
  type        = string
  description = "ns argocd is installed in"
}
