variable "admin_rbac_group" {
  type        = string
  description = "rbac group in idm for admin access via netbird"
}

variable "user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via netbird"
}

variable "environment_list" {
  description = "env repos to pre-create k8s groups for"
}

variable "netbird_project_id" {
  description = "project id in zitadel of netbird project"
}

variable "build_setup_key_secret_key" {
  type        = string
  description = "secret key for build server setup key"
}

variable "gw_setup_key_secret_key" {
  type        = string
  description = "secret key for gw setup key"
}

variable "setup_key_secret_name" {
  description = "secret name to put access tokens"
}

variable "setup_key_secret_namespace" {
  description = "ns to create secret"
}


