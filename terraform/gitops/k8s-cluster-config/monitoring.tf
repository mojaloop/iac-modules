module "generate_monitoring_files" {
  source = "../generate-files"
  var_map = {
    grafana_chart_repo                   = var.grafana_chart_repo
    loki_chart_version                   = try(var.common_var_map.loki_chart_version, local.loki_chart_version)
    prometheus_operator_version          = try(var.common_var_map.prometheus_operator_version, local.prometheus_operator_version)
    prometheus_operator_release_name     = local.prometheus_operator_release_name
    loki_release_name                    = local.loki_release_name
    grafana_operator_version             = try(var.common_var_map.grafana_operator_version, local.grafana_operator_version)
    grafana_version                      = try(var.common_var_map.grafana_version, local.grafana_version)
    tempo_chart_version                  = try(var.common_var_map.tempo_chart_version, local.tempo_chart_version)
    monitoring_namespace                 = var.monitoring_namespace
    gitlab_server_url                    = var.gitlab_server_url
    gitlab_project_url                   = var.gitlab_project_url
    public_subdomain                     = var.public_subdomain
    client_id                            = data.vault_generic_secret.grafana_oauth_client_id.data.value
    client_secret                        = data.vault_generic_secret.grafana_oauth_client_secret.data.value
    enable_oidc                          = var.enable_grafana_oidc
    storage_class_name                   = var.storage_class_name
    groups                               = var.gitlab_admin_group_name
    prom-mojaloop-url                    = "http://prometheus-operated:9090"
    admin_secret_pw_key                  = "admin-pw"
    admin_secret_user_key                = "admin-user"
    admin_secret                         = "grafana-admin-secret"
    admin_user_name                      = "grafana-admin"
    alertmanager_jira_secret_ref         = "${var.cluster_name}/jira-prometheus-integration-secret-key"
    monitoring_sync_wave                 = var.monitoring_sync_wave
    monitoring_post_config_sync_wave     = var.monitoring_post_config_sync_wave
    ingress_class                        = var.grafana_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways        = var.istio_create_ingress_gateways
    istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    grafana_wildcard_gateway             = local.grafana_wildcard_gateway
    loki_ingester_pvc_size               = try(var.common_var_map.loki_ingester_pvc_size, local.loki_ingester_pvc_size)
    prometheus_pvc_size                  = try(var.common_var_map.prometheus_pvc_size, local.prometheus_pvc_size)
    loki_ingester_retention_period       = try(var.common_var_map.loki_ingester_retention_period, local.loki_ingester_retention_period)
    prometheus_retention_period          = try(var.common_var_map.prometheus_retention_period, local.prometheus_retention_period)
    alertmanager_enabled                 = try(var.common_var_map.alertmanager_enabled, false)
    loki_minio_endpoint                  = "haproxy.${var.cluster_name}.devbaremetal.moja-onprem.net:9000" # TODO: how do we parametrize it properly? 
    loki_minio_bucket                    = "${var.cluster_name}-loki"
    minio_loki_secret_credentials_ref    = "${var.cluster_name}/minio-loki-secret-credentials"
  }
  file_list       = [for f in fileset(local.monitoring_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.monitoring_app_file, f))]
  template_path   = local.monitoring_template_path
  output_path     = "${var.output_dir}/monitoring"
  app_file        = local.monitoring_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "grafana_ingress_internal_lb" {
  type        = bool
  description = "grafana_ingress_internal_lb"
  default     = true
}
variable "enable_grafana_oidc" {
  type    = bool
  default = false
}

variable "grafana_oidc_client_secret_secret_key" {
  type        = string
  description = "grafana_oidc_client_secret_secret_key"
  default     = "grafana_oauth_client_secret"
}

variable "grafana_oidc_client_id_secret_key" {
  type        = string
  description = "grafana_oidc_client_id_secret_key"
  default     = "grafana_oauth_client_id"
}

variable "grafana_chart_repo" {
  type        = string
  default     = "https://grafana.github.io/helm-charts"
  description = "grafana_chart_repo"
}

variable "monitoring_sync_wave" {
  type        = string
  description = "monitoring_sync_wave"
  default     = "-5"
}
variable "monitoring_post_config_sync_wave" {
  type        = string
  description = "monitoring_sync_wave"
  default     = "-4"
}

variable "monitoring_namespace" {
  type        = string
  description = "monitoring_namespace"
  default     = "monitoring"
}

locals {
  grafana_wildcard_gateway         = var.grafana_ingress_internal_lb ? "internal" : "external"
  loki_release_name                = "loki"
  prometheus_operator_release_name = "prom"
  loki_chart_version               = "2.13.0"
  prometheus_operator_version      = "8.22.8"
  tempo_chart_version              = "2.6.0"
  grafana_version                  = "10.2.3"
  grafana_operator_version         = "3.5.11"
  monitoring_template_path         = "${path.module}/../generate-files/templates/monitoring"
  monitoring_app_file              = "monitoring-app.yaml"
  loki_ingester_pvc_size           = "50Gi"
  prometheus_pvc_size              = "50Gi"
  loki_ingester_retention_period   = "72h"
  prometheus_retention_period      = "10d"
}
