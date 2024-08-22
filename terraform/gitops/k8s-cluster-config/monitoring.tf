module "generate_monitoring_files" {
  source = "../generate-files"
  var_map = {
    grafana_crd_version_tag                = try(var.common_var_map.grafana_crd_version_tag, local.grafana_crd_version_tag)
    prometheus_crd_version                 = try(var.common_var_map.prometheus_crd_version, local.prometheus_crd_version)
    loki_chart_version                     = try(var.common_var_map.loki_chart_version, local.loki_chart_version)
    prometheus_operator_version            = try(var.common_var_map.prometheus_operator_version, local.prometheus_operator_version)
    prometheus_operator_release_name       = local.prometheus_operator_release_name
    prometheus_process_exporter_version    = try(var.common_var_map.prometheus_process_exporter_version, local.prometheus_process_exporter_version)
    loki_release_name                      = local.loki_release_name
    grafana_operator_version               = try(var.common_var_map.grafana_operator_version, local.grafana_operator_version)
    grafana_version                        = try(var.common_var_map.grafana_version, local.grafana_version)
    grafana_dashboard_tag                  = try(var.common_var_map.grafana_dashboard_tag, local.grafana_dashboard_tag)
    tempo_chart_version                    = try(var.common_var_map.tempo_chart_version, local.tempo_chart_version)
    monitoring_namespace                   = var.monitoring_namespace
    gitlab_server_url                      = var.gitlab_server_url
    zitadel_server_url                     = var.zitadel_server_url
    gitlab_project_url                     = var.gitlab_project_url
    public_subdomain                       = var.public_subdomain
    client_id                              = try(data.vault_kv_secret_v2.grafana_oauth_client_id[0].data.value, "")
    client_secret                          = try(data.vault_kv_secret_v2.grafana_oauth_client_secret[0].data.value, "")
    enable_oidc                            = var.enable_grafana_oidc
    storage_class_name                     = var.storage_class_name
    zitadel_project_id                     = var.zitadel_project_id
    grafana_admin_rbac_group               = var.grafana_admin_rbac_group
    grafana_user_rbac_group                = var.grafana_user_rbac_group
    prom-mojaloop-url                      = "http://prometheus-operated:9090"
    admin_secret_pw_key                    = "admin-pw"
    admin_secret_user_key                  = "admin-user"
    admin_secret                           = "grafana-admin-secret"
    admin_user_name                        = "grafana-admin"
    alertmanager_jira_secret_ref           = "${var.cluster_name}/jira-prometheus-integration-secret-key"
    alertmanager_slack_external_secret_ref = "tenancy/${local.alertmanager_slack_external_secret_name}"
    monitoring_sync_wave                   = var.monitoring_sync_wave
    monitoring_post_config_sync_wave       = var.monitoring_post_config_sync_wave
    ingress_class                          = var.grafana_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways          = var.istio_create_ingress_gateways
    loki_ingester_pvc_size                 = try(var.common_var_map.loki_ingester_pvc_size, local.loki_ingester_pvc_size)
    prometheus_pvc_size                    = try(var.common_var_map.prometheus_pvc_size, local.prometheus_pvc_size)
    loki_retention_enabled                 = try(var.common_var_map.loki_retention_enabled, local.loki_retention_enabled)
    loki_ingester_retention_period         = try(var.common_var_map.loki_ingester_retention_period, local.loki_ingester_retention_period)
    loki_ingester_max_chunk_age            = try(var.common_var_map.loki_ingester_max_chunk_age, local.loki_ingester_max_chunk_age)
    prometheus_retention_period            = try(var.common_var_map.prometheus_retention_period, local.prometheus_retention_period)
    alertmanager_enabled                   = try(var.common_var_map.alertmanager_enabled, false)
    alertmanager_slack_integration_enabled = try(var.common_var_map.alertmanager_slack_integration_enabled, false)
    alertmanager_jira_integration_enabled  = try(var.common_var_map.alertmanager_jira_integration_enabled, false)
    ceph_loki_credentials_secret_name     = "ceph-loki-credentials-secret"
    ceph_api_url                          = var.ceph_api_url
    ceph_loki_bucket                      = local.ceph_loki_bucket
    ceph_loki_user_key                    = "${var.cluster_name}/loki_bucket_access_key_id"
    ceph_loki_password_key                = "${var.cluster_name}/loki_bucket_secret_key_id"
    ceph_tempo_credentials_secret_name    = "ceph-tempo-credentials-secret"
    ceph_tempo_user_key                   = "${var.cluster_name}/tempo_bucket_access_key_id"
    ceph_tempo_password_key               = "${var.cluster_name}/tempo_bucket_secret_key_id"
    ceph_tempo_bucket                     = local.ceph_tempo_bucket
    tempo_retention_period                 = try(var.common_var_map.tempo_retention_period, local.tempo_retention_period)
    external_secret_sync_wave              = var.external_secret_sync_wave
    prom_tsdb_max_block_duration           = try(var.common_var_map.prom_tsdb_max_block_duration, local.prom_tsdb_max_block_duration)
    prom_tsdb_min_block_duration           = try(var.common_var_map.prom_tsdb_min_block_duration, local.prom_tsdb_min_block_duration)
    grafana_subdomain                      = local.grafana_subdomain
    grafana_fqdn                           = local.grafana_fqdn
    grafana_istio_gateway_namespace        = local.grafana_istio_gateway_namespace
    grafana_istio_wildcard_gateway_name    = local.vault_istio_wildcard_gateway_name

    # central observability configs
    cluster_label                      = var.cluster_name # cluster identifier in central observability stack
    enable_central_observability_write = try(var.common_var_map.enable_central_observability_write, local.enable_central_observability_write)
    enable_central_observability_read  = try(var.common_var_map.enable_central_observability_read, local.enable_central_observability_read)
    central_observability_endpoint     = var.central_observability_endpoint
    central_observability_tenant_id    = try(var.common_var_map.central_observability_tenant_id, local.central_observability_tenant_id)

    alertmanager_fqdn = local.alertmanager_fqdn
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
  default     = "grafana_oidc_client_secret"
}

variable "grafana_oidc_client_id_secret_key" {
  type        = string
  description = "grafana_oidc_client_id_secret_key"
  default     = "grafana_oidc_client_id"
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
  grafana_crd_version_tag             = "v5.6.0"
  prometheus_crd_version              = "8.0.1"
  grafana_wildcard_gateway            = var.grafana_ingress_internal_lb ? "internal" : "external"
  loki_release_name                   = "loki"
  prometheus_operator_release_name    = "prom"
  loki_chart_version                  = "2.13.0"
  prometheus_operator_version         = "8.22.8"
  prometheus_process_exporter_version = "0.4.2"
  tempo_chart_version                 = "3.1.0"
  grafana_version                     = "10.2.3"
  grafana_dashboard_tag               = "v16.3.0-snapshot.17" # TODO: update once v16.1.x is published
  grafana_operator_version            = "3.5.11"
  monitoring_template_path            = "${path.module}/../generate-files/templates/monitoring"
  monitoring_app_file                 = "monitoring-app.yaml"
  loki_ingester_pvc_size              = "10Gi"
  prometheus_pvc_size                 = "50Gi"
  loki_retention_enabled              = true
  loki_ingester_retention_period      = "72h"
  loki_ingester_max_chunk_age         = "2h"
  prometheus_retention_period         = "10d"
  tempo_retention_period              = "72h"
  prom_tsdb_min_block_duration        = "30m"
  prom_tsdb_max_block_duration        = "30m"
  grafana_public_fqdn                 = "grafana.${var.public_subdomain}"
  grafana_private_fqdn                = "grafana.${var.private_subdomain}"
  grafana_subdomain                   = local.grafana_wildcard_gateway == "external" ? var.public_subdomain : var.private_subdomain
  grafana_fqdn                        = local.grafana_wildcard_gateway == "external" ? "grafana.${var.public_subdomain}" : "grafana.${var.private_subdomain}"
  grafana_istio_gateway_namespace     = local.grafana_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  grafana_istio_wildcard_gateway_name = local.grafana_wildcard_gateway == "external" ? local.istio_external_wildcard_gateway_name : local.istio_internal_wildcard_gateway_name
  enable_central_observability_write  = false
  enable_central_observability_read   = false
  central_observability_tenant_id     = "infitx"

  alertmanager_fqdn                       = "alertmanager.${var.private_subdomain}"
  alertmanager_prod_alerts_enabled        = try(var.common_var_map.alertmanager_prod_alerts_enabled, false)
  alertmanager_slack_external_secret_name = local.alertmanager_prod_alerts_enabled ? "slack-prod-alert-notifications" : "slack-dev-alert-notifications"
}
