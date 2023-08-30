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
    vault_seal_token_secret                  = "vault-seal-token-secret"
    vault_gitlab_credentials_secret          = "vault-gitlab-credentials-secret"
    vault_oidc_client_id_secret              = "vault-oidc-client-id-secret"
    vault_oidc_client_secret_secret          = "vault-oidc-client-secret-secret"
    vault_seal_token_secret_key              = "${var.cluster_name}/${var.vault_seal_token_secret_key}"
    vault_gitlab_credentials_secret_key      = var.vault_gitlab_credentials_secret_key
    vault_oidc_client_id_secret_key          = "${var.cluster_name}/${var.vault_oidc_client_id_secret_key}"
    vault_oidc_client_secret_secret_key      = "${var.cluster_name}/${var.vault_oidc_client_secret_secret_key}"
    cloud_region                             = local.cloud_region
    vault_k8s_auth_path                      = var.vault_k8s_auth_path
    public_subdomain                         = var.public_subdomain
    ingress_class                            = var.vault_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_internal_wildcard_gateway_name     = local.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace         = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name     = local.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace         = var.istio_external_gateway_namespace
    vault_wildcard_gateway                   = local.vault_wildcard_gateway
    istio_create_ingress_gateways            = var.istio_create_ingress_gateways
    consul_namespace                         = var.consul_namespace
    gitlab_server_url                        = var.gitlab_server_url
    gitlab_admin_group_name                  = var.gitlab_admin_group_name
    gitlab_readonly_group_name               = var.gitlab_readonly_group_name
    enable_vault_oidc                        = var.enable_vault_oidc
    cluster_name                             = var.cluster_name
    transit_vault_url                        = var.transit_vault_url
    transit_vault_key_name                   = var.transit_vault_key_name
  }

  file_list = ["charts/vault/Chart.yaml", "charts/vault/values.yaml",
    "charts/vault-config-operator/Chart.yaml", "charts/vault-config-operator/values.yaml",
    "post-config.yaml", "vault-config-operator.yaml", "vault-extsecret.yaml", "vault-helm.yaml",
  "istio-gateway.yaml"]
  template_path   = "${path.module}/generate-files/templates/vault"
  output_path     = "${var.output_dir}/vault"
  app_file        = "vault-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "vault_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-7"
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
  description = "vault_config_operator_sync_wave"
  default     = "-6"
}

variable "vault_cm_sync_wave" {
  type        = string
  description = "vault_cm_sync_wave"
  default     = "-8"
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

variable "vault_gitlab_credentials_secret_key" {
  type        = string
  description = "vault_gitlab_credentials_secret_key"
  default     = "tenancy/gitlab_ci_pat"
}

variable "vault_seal_token_secret_key" {
  type        = string
  description = "vault_seal_token_secret_key"
  default     = "env_token"
}

variable "transit_vault_url" {
  type        = string
  description = "url to vault for transit autounseal"
}

variable "transit_vault_key_name" {
  type        = string
  description = "key for transit autounseal"
}

variable "vault_oidc_client_secret_secret_key" {
  type        = string
  description = "vault_oidc_client_secret_secret_key"
  default     = "vault_oauth_client_secret"
}

variable "vault_oidc_client_id_secret_key" {
  type        = string
  description = "vault_oidc_client_id_secret_key"
  default     = "vault_oauth_client_id"
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
  type    = bool
  default = false
}

locals {
  vault_wildcard_gateway = var.vault_ingress_internal_lb ? "internal" : "external"
}
