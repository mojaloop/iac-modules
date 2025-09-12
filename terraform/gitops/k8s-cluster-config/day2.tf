module "generate_day2_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                         = var.gitlab_project_url
    day2_namespace                             = var.day2_namespace
    day2_sync_wave                             = var.day2_sync_wave
    argocd_helm_version                        = var.argocd_helm_version
    argocd_dns_subdomain                       = var.argocd_dns_subdomain
    zitadel_server_url                         = var.zitadel_server_url
    argocd_readonly_rbac_group                 = var.argocd_readonly_rbac_group
    argocd_admin_rbac_group                    = var.argocd_admin_rbac_group
    zitadel_project_id                         = var.zitadel_project_id
    zitadel_grant_prefix                       = var.zitadel_grant_prefix
    argocd_helm_applicationsetcontroller_log_level = var.argocd_helm_applicationsetcontroller_log_level
    argocd_helm_controller_log_level           = var.argocd_helm_controller_log_level
    argocd_helm_reposerver_log_level           = var.argocd_helm_reposerver_log_level
    argocd_helm_server_log_level               = var.argocd_helm_server_log_level
    argocd_helm_kube_version                   = var.argocd_helm_kube_version
    argocd_helm_git_plugin_version             = var.argocd_helm_git_plugin_version
    argocd_envsubst_version                    = var.argocd_envsubst_version
    argocd_rollout_extension_version           = var.argocd_rollout_extension_version
    argocd_download_tools_golang_image_version = var.argocd_download_tools_golang_image_version
    external_secrets_helm_version              = var.external_secrets_helm_version
    external_secrets_namespace                 = var.external_secrets_namespace
    cluster_name                               = var.cluster_name
    kubernetes_oidc_k8s_user_group             = var.kubernetes_oidc_k8s_user_group
    kubernetes_oidc_k8s_admin_group            = var.kubernetes_oidc_k8s_admin_group
  }
  file_list       = [for f in fileset(local.base_utils_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.day2_app_file, f))]
  template_path   = local.base_utils_template_path
  output_path     = "${var.output_dir}/day2"
  app_file        = local.base_utils_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  base_utils_template_path               = "${path.module}/../generate-files/templates/day2"
  day2_app_file                    = "day2-app.yaml"
}

variable "argocd_helm_version" {
  type        = string
  description = "argocd_helm_version"
  default     = "8.0.14"
}

variable "argocd_dns_subdomain" {
  type        = string
  description = "argocd_dns_subdomain"
}
variable "day2_namespace" {
  type        = string
  description = "day2_namespace"
  default     = "day2"
}

variable "day2_sync_wave" {
  type        = string
  description = "day2_sync_wave"
  default     = "-18"
}
variable "zitadel_server_url" {
  type        = string
  description = "zitadel_server_url"
}

variable "argocd_readonly_rbac_group" {
  type        = string
  description = "argocd_readonly_rbac_group"
}
variable "argocd_admin_rbac_group" {
  type        = string
  description = "argocd_admin_rbac_group"
}
variable "zitadel_project_id" {
  type        = string
  description = "zitadel_project_id"
}
variable "zitadel_grant_prefix" {
  type        = string
  description = "zitadel_grant_prefix"
}
variable "argocd_helm_applicationsetcontroller_log_level" {
  type        = string
  description = "argocd_helm_applicationsetcontroller_log_level"
  default     = "info"
}
variable "argocd_helm_controller_log_level" {
  type        = string
  description = "argocd_helm_controller_log_level"
  default     = "info"
}
variable "argocd_helm_reposerver_log_level" {
  type        = string
  description = "argocd_helm_reposerver_log_level"
  default     = "info"
}
variable "argocd_helm_server_log_level" {
  type        = string
  description = "argocd_helm_server_log_level"
  default     = "info"
}
variable "argocd_helm_kube_version" {
  type        = string
  description = "argocd_helm_kube_version"
  default     = "1.31.0"
}
variable "argocd_helm_git_plugin_version" {
  type        = string
  description = "argocd_helm_git_plugin_version"
  default     = "1.3.0"
}
variable "argocd_envsubst_version" {
  type        = string
  description = "argocd_envsubst_version"
  default     = "1.0.3"
}
variable "argocd_rollout_extension_version" {
  type        = string
  description = "argocd_rollout_extension_version"
  default     = "0.3.7"
}
variable "argocd_download_tools_golang_image_version" {
  type        = string
  description = "argocd_download_tools_golang_image_version"
  default     = "1.22.4-alpine3.20"
}
variable "external_secrets_helm_version" {
  type        = string
  description = "external_secrets_helm_version"
  default     = "0.15.1"
}

variable "external_secrets_namespace" {
  type        = string
  description = "external_secrets_namespace"
  default     = "external-secrets"
}

variable "kubernetes_oidc_k8s_user_group" {
  type        = string
  description = "kubernetes_oidc_k8s_user_group"
}

variable "kubernetes_oidc_k8s_admin_group" {
  type        = string
  description = "kubernetes_oidc_k8s_admin_group"
}