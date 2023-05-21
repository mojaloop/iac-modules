module "generate_vault_files" {
  source = "./generate-files"
  var_map = {
    vault_chart_repo                         = var.vault_chart_repo
    vault_namespace                          = var.vault_namespace
    vault_config_operator_namespace          = var.vault_config_operator_namespace
    vault_chart_version                      = var.vault_chart_version
    vault_sync_wave                          = var.vault_sync_wave
    vault_cm_sync_wave                       = var.vault_cm_sync_wave
    vault_config_operator_sync_wave          = var.vault_config_operator_sync_wave
    external_secret_sync_wave                = var.external_secret_sync_wave
    vault_config_operator_helm_chart_repo    = var.vault_config_operator_helm_chart_repo
    vault_config_operator_helm_chart_version = var.vault_config_operator_helm_chart_version
    gitlab_variables_api_url                 = "${var.gitlab_api_url}/projects/${var.current_gitlab_project_id}/variables"
    gitlab_project_url                       = var.gitlab_project_url
    vault_kms_seal_kms_key_id                = var.vault_kms_seal_kms_key_id
    gitlab_key_vault_iam_user_secret_key     = var.gitlab_key_vault_iam_user_secret_key
    gitlab_key_vault_iam_user_access_key     = var.gitlab_key_vault_iam_user_access_key
    vault_seal_credentials_secret            = var.vault_seal_credentials_secret
    vault_gitlab_credentials_secret          = var.vault_gitlab_credentials_secret
    cloud_region                             = local.cloud_region
    vault_k8s_auth_path                      = var.vault_k8s_auth_path
    public_subdomain                         = var.public_subdomain
    ingress_class                            = var.vault_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    consul_namespace                         = var.consul_namespace
    gitlab_key_gitlab_ci_pat                 = var.gitlab_key_gitlab_ci_pat
    gitlab_server_url                        = var.gitlab_server_url
    gitlab_admin_group_name                  = var.gitlab_admin_group_name
    gitlab_readonly_group_name               = var.gitlab_readonly_group_name
    vault_oauth_client_secret                = var.vault_oauth_client_secret
    vault_oauth_client_id                    = var.vault_oauth_client_id
    enable_vault_oidc                        = var.enable_vault_oidc
  }

  file_list = ["charts/vault/Chart.yaml", "charts/vault/values.yaml",
    "charts/vault-config-operator/Chart.yaml", "charts/vault-config-operator/values.yaml",
  "post-config.yaml", "vault-config-operator.yaml", "vault-extsecret.yaml", "vault-helm.yaml"]
  template_path   = "${path.module}/generate-files/templates/vault"
  output_path     = "${var.output_dir}/vault"
  app_file        = "vault-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "vault_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-5"
}

variable "vault_namespace" {
  type        = string
  description = "vault_namespace"
  default     = "vault"
}

variable "vault_config_operator_namespace" {
  type        = string
  description = "vault_config_operator_namespace"
  default     = "vault-config"
}

variable "vault_config_operator_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-5"
}

variable "vault_cm_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-6"
}

variable "vault_chart_repo" {
  type        = string
  description = "vault_chart_repo"
  default     = "https://helm.releases.hashicorp.com"
}
variable "vault_chart_version" {
  type        = string
  description = "vault_chart_version"
  default     = "0.23.0"
}
variable "vault_config_operator_helm_chart_repo" {
  type        = string
  description = "vault_config_operator_helm_chart_repo"
  default     = "https://redhat-cop.github.io/vault-config-operator"
}
variable "vault_config_operator_helm_chart_version" {
  type        = string
  description = "vault_config_operator_helm_chart_version"
  default     = "0.8.9"
}
variable "gitlab_key_vault_iam_user_access_key" {
  type        = string
  description = "gitlab_key_vault_iam_user_access_key"
}
variable "gitlab_key_vault_iam_user_secret_key" {
  type        = string
  description = "gitlab_key_vault_iam_user_secret_key"
}
variable "vault_kms_seal_kms_key_id" {
  type        = string
  description = "vault_kms_seal_kms_key_id"
}

variable "vault_gitlab_credentials_secret" {
  type = string
  description = "vault_gitlab_credentials_secret"
  default = "vault-gitlab-credentials-secret"
}

variable "vault_seal_credentials_secret" {
  type = string
  description = "vault_seal_credentials_secret"
  default = "vault-seal-credentials-secret"
}

variable "vault_ingress_internal_lb" {
  type        = bool
  description = "vault_ingress_class"
  default     = true
}
variable "vault_k8s_auth_path" {
  type        = string
  description = "vault_k8s_auth_path"
  default     = "auth/kubernetes"
}

variable "enable_vault_oidc" {
  type = bool
  default = false
}

variable "vault_oauth_client_id" {
  type = string
  default = ""
  description = "vault_oauth_client_id"
}

variable "vault_oauth_client_secret" {
  type = string
  default = ""
  description = "vault_oauth_client_secret"
  sensitive = true
}
