variable "gitlab_zitadel_project_name" {
  type        = string
  description = "zitadel project name for gitlab"
  default     = "gitlab"
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
