module "generate_monitoring_files" {
  source = "../generate-files"
  var_map = {
    grafana_crd_version_tag                    = try(var.common_var_map.grafana_crd_version_tag, local.grafana_crd_version_tag)
    prometheus_crd_version                     = try(var.common_var_map.prometheus_crd_version, local.prometheus_crd_version)
    loki_repo                                  = local.loki_repo
    loki_chart_version                         = try(var.common_var_map.loki_chart_version, local.loki_chart_version)
    prometheus_operator_repo                   = local.prometheus_operator_repo
    prometheus_operator_version                = try(var.common_var_map.prometheus_operator_version, local.prometheus_operator_version)
    prometheus_operator_release_name           = local.prometheus_operator_release_name
    prometheus_process_exporter_version        = try(var.common_var_map.prometheus_process_exporter_version, local.prometheus_process_exporter_version)
    process_exporter_enabled                   = try(var.common_var_map.process_exporter_enabled, local.process_exporter_enabled)
    loki_release_name                          = local.loki_release_name
    grafana_operator_repo                      = local.grafana_operator_repo
    grafana_operator_version                   = try(var.common_var_map.grafana_operator_version, local.grafana_operator_version)
    grafana_version                            = try(var.common_var_map.grafana_version, local.grafana_version)
    grafana_dashboard_tag                      = try(var.common_var_map.grafana_dashboard_tag, local.grafana_dashboard_tag)
    grafana_dashboard_tag_iac_modules          = try(var.common_var_map.grafana_dashboard_tag_iac_modules, local.grafana_dashboard_tag_iac_modules)
    metrics_server_chart_version               = try(var.common_var_map.metrics_server_chart_version, local.metrics_server_chart_version)
    metrics_server_replicas                    = var.metrics_server_replicas
    opentelemetry_chart_version                = try(var.common_var_map.opentelemetry_chart_version, local.opentelemetry_chart_version)
    monitoring_namespace                       = var.monitoring_namespace
    gitlab_server_url                          = var.gitlab_server_url
    zitadel_server_url                         = var.zitadel_server_url
    gitlab_project_url                         = var.gitlab_project_url
    public_subdomain                           = var.public_subdomain
    client_id                                  = try(data.vault_kv_secret_v2.grafana_oauth_client_id[0].data.value, "")
    client_secret                              = try(data.vault_kv_secret_v2.grafana_oauth_client_secret[0].data.value, "")
    enable_oidc                                = var.enable_grafana_oidc
    storage_class_name                         = var.storage_class_name
    zitadel_project_id                         = var.zitadel_project_id
    grafana_admin_rbac_group                   = var.grafana_admin_rbac_group
    grafana_user_rbac_group                    = var.grafana_user_rbac_group
    prom-mojaloop-url                          = "http://prometheus-operated:9090"
    admin_secret_pw_key                        = "admin-pw"
    admin_secret_user_key                      = "admin-user"
    admin_secret                               = "grafana-admin-secret"
    admin_user_name                            = "grafana-admin"
    alertmanager_jira_secret_ref               = "${var.cluster_name}/jira-prometheus-integration-secret-key"
    alertmanager_slack_external_secret_ref     = "tenancy/${local.alertmanager_slack_external_secret_name}"
    monitoring_sync_wave                       = var.monitoring_sync_wave
    monitoring_post_config_sync_wave           = var.monitoring_post_config_sync_wave
    ingress_class                              = var.grafana_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways              = var.istio_create_ingress_gateways
    loki_ingester_pvc_size                     = try(var.common_var_map.loki_ingester_pvc_size, local.loki_ingester_pvc_size)
    prometheus_pvc_size                        = try(var.common_var_map.prometheus_pvc_size, local.prometheus_pvc_size)
    loki_ingester_retention_period             = try(var.common_var_map.loki_ingester_retention_period, local.loki_ingester_retention_period)
    loki_ingester_max_chunk_age                = try(var.common_var_map.loki_ingester_max_chunk_age, local.loki_ingester_max_chunk_age)
    loki_ingester_replication_factor           = try(var.common_var_map.loki_ingester_replication_factor, local.loki_ingester_replication_factor)
    loki_distributor_replica_count             = try(var.common_var_map.loki_distributor_replica_count, local.loki_distributor_replica_count)
    loki_ingester_replica_count                = try(var.common_var_map.loki_ingester_replica_count, local.loki_ingester_replica_count)
    loki_querier_replica_count                 = try(var.common_var_map.loki_querier_replica_count, local.loki_querier_replica_count)
    loki_distributor_requests_cpu              = try(var.common_var_map.loki_distributor_requests_cpu, local.loki_distributor_requests_cpu)
    loki_distributor_requests_memory           = try(var.common_var_map.loki_distributor_requests_memory, local.loki_distributor_requests_memory)
    loki_distributor_limits_cpu                = try(var.common_var_map.loki_distributor_limits_cpu, local.loki_distributor_limits_cpu)
    loki_distributor_limits_memory             = try(var.common_var_map.loki_distributor_limits_memory, local.loki_distributor_limits_memory)
    loki_ingester_requests_cpu                 = try(var.common_var_map.loki_ingester_requests_cpu, local.loki_ingester_requests_cpu)
    loki_ingester_requests_memory              = try(var.common_var_map.loki_ingester_requests_memory, local.loki_ingester_requests_memory)
    loki_ingester_limits_cpu                   = try(var.common_var_map.loki_ingester_limits_cpu, local.loki_ingester_limits_cpu)
    loki_ingester_limits_memory                = try(var.common_var_map.loki_ingester_limits_memory, local.loki_ingester_limits_memory)
    loki_querier_limits_cpu                    = try(var.common_var_map.loki_querier_limits_cpu, local.loki_querier_limits_cpu)
    loki_querier_limits_memory                 = try(var.common_var_map.loki_querier_limits_memory, local.loki_querier_limits_memory)
    loki_query_frontend_limits_cpu             = try(var.common_var_map.loki_query_frontend_limits_cpu, local.loki_query_frontend_limits_cpu)
    loki_query_frontend_limits_memory          = try(var.common_var_map.loki_query_frontend_limits_memory, local.loki_query_frontend_limits_memory)
    loki_query_scheduler_limits_cpu            = try(var.common_var_map.loki_query_scheduler_limits_cpu, local.loki_query_scheduler_limits_cpu)
    loki_query_scheduler_limits_memory         = try(var.common_var_map.loki_query_scheduler_limits_memory, local.loki_query_scheduler_limits_memory)
    loki_compactor_limits_cpu                  = try(var.common_var_map.loki_compactor_limits_cpu, local.loki_compactor_limits_cpu)
    loki_compactor_limits_memory               = try(var.common_var_map.loki_compactor_limits_memory, local.loki_compactor_limits_memory)
    alloy_limits_memory                        = try(var.common_var_map.alloy_limits_memory, local.alloy_limits_memory)
    alloy_limits_cpu                           = try(var.common_var_map.alloy_limits_cpu, local.alloy_limits_cpu)
    prometheus_scrape_interval                 = try(var.common_var_map.prometheus_scrape_interval, local.prometheus_scrape_interval)
    prometheus_rate_interval                   = try(var.common_var_map.prometheus_rate_interval, local.prometheus_rate_interval)
    prometheus_retention_period                = try(var.common_var_map.prometheus_retention_period, local.prometheus_retention_period)
    prometheus_limits_cpu                      = try(var.common_var_map.prometheus_limits_cpu, "1000m")
    prometheus_limits_memory                   = try(var.common_var_map.prometheus_limits_memory, "6Gi")
    prometheus_requests_cpu                    = try(var.common_var_map.prometheus_requests_cpu, "500m")
    prometheus_requests_memory                 = try(var.common_var_map.prometheus_requests_memory, "1Gi")
    alertmanager_enabled                       = try(var.common_var_map.alertmanager_enabled, false)
    alertmanager_limits_cpu                    = try(var.common_var_map.alertmanager_limits_cpu, "200m")
    alertmanager_limits_memory                 = try(var.common_var_map.alertmanager_limits_memory, "512Mi")
    alertmanager_requests_cpu                  = try(var.common_var_map.alertmanager_requests_cpu, "100m")
    alertmanager_requests_memory               = try(var.common_var_map.alertmanager_requests_memory, "128Mi")
    alertmanager_slack_integration_enabled     = try(var.common_var_map.alertmanager_slack_integration_enabled, false)
    alertmanager_jira_integration_enabled      = try(var.common_var_map.alertmanager_jira_integration_enabled, false)
    promtail_kubernetes_sd_configs             = try(var.common_var_map.promtail_kubernetes_sd_configs, [{ role = "pod" }])
    object_store_loki_credentials_secret_name  = "ceph-loki-credentials-secret"
    object_store_api_url                       = var.object_store_api_url
    object_store_region                        = var.object_store_region
    object_store_regional_endpoint             = var.object_store_regional_endpoint
    object_storage_path_style                  = var.object_storage_path_style
    object_store_insecure_connection           = var.object_store_insecure_connection
    object_store_insecure_skip_verify          = var.object_store_insecure_skip_verify
    loki_bucket                                = local.loki_bucket
    object_store_loki_access_key               = "${var.cluster_name}/loki_bucket_access_key_id"
    object_store_tempo_credentials_secret_name = "ceph-tempo-credentials-secret"
    object_store_tempo_access_key              = "${var.cluster_name}/tempo_bucket_access_key_id"
    tempo_bucket                               = local.tempo_bucket
    tempo_retention_period                     = try(var.common_var_map.tempo_retention_period, local.tempo_retention_period)
    external_secret_sync_wave                  = var.external_secret_sync_wave
    prom_tsdb_max_block_duration               = try(var.common_var_map.prom_tsdb_max_block_duration, local.prom_tsdb_max_block_duration)
    prom_tsdb_min_block_duration               = try(var.common_var_map.prom_tsdb_min_block_duration, local.prom_tsdb_min_block_duration)
    grafana_subdomain                          = local.grafana_subdomain
    grafana_fqdn                               = local.grafana_fqdn
    grafana_private_fqdn                       = local.grafana_private_fqdn
    grafana_istio_gateway_namespace            = local.grafana_istio_gateway_namespace
    grafana_istio_wildcard_gateway_name        = local.vault_istio_wildcard_gateway_name
    cluster                                    = var.app_var_map.cluster
    loki_canary_repo                           = local.loki_canary_repo
    loki_canary_chart_version                  = local.loki_canary_chart_version
    log_alert_patterns                         = try(var.common_var_map.log_alert_patterns, var.log_alert_patterns)
    # central observability configs
    cluster_label                      = var.cluster_name # cluster identifier in central observability stack
    enable_central_observability_write = try(var.common_var_map.enable_central_observability_write, local.enable_central_observability_write)
    enable_central_observability_read  = try(var.common_var_map.enable_central_observability_read, local.enable_central_observability_read)
    central_observability_endpoint     = var.central_observability_endpoint
    central_observability_tenant_id    = try(var.common_var_map.central_observability_tenant_id, local.central_observability_tenant_id)
    enable_central_loki_write          = try(var.common_var_map.enable_central_loki_write, local.enable_central_loki_write)
    central_loki_endpoint              = var.central_loki_endpoint
    namespaces_to_central_loki         = try(var.common_var_map.namespaces_to_central_loki, local.namespaces_to_central_loki)
    alertmanager_fqdn = local.alertmanager_fqdn
    tolerations       = var.common_var_map.monitoring_workload_tolerations
    prometheus_crd_repo = local.prometheus_crd_repo
    opentelemetry_repo = local.opentelemetry_repo
    alloy_repo = local.alloy_repo
    metrics_server_chart_repo = local.metrics_server_chart_repo
    alerts = merge(local.alerts, try(var.common_var_map.alerts, {}))
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
  default     = "oci://ghcr.io/grafana/helm-charts"
  description = "grafana_chart_repo"
}

variable "opentelemetry_chart_repo" {
  type        = string
  default     = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  description = "opentelemetry_chart_repo"
}

variable "alloy_chart_repo" {
  type        = string
  default     = "https://grafana.github.io/helm-charts"
  description = "alloy_chart_repo"
}

variable "prometheus_operator_repo" {
  type        = string
  default     = "oci://registry-1.docker.io/bitnamicharts"
  description = "prometheus_operator_repo"
}

variable "loki_repo" {
  type        = string
  default     = "https://grafana.github.io/helm-charts"
  description = "loki_repo"
}

variable "loki_canary_repo" {
    type        = string
    default     = "https://grafana.github.io/helm-charts"
  description = "loki_canary_repo"
}

variable "grafana_operator_repo" {
  type        = string
  default     = "oci://ghcr.io/grafana/helm-charts/"
  description = "grafana_operator_repo"
}

variable "prometheus_crd_repo" {
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  description = "prometheus_crd_repo"
}

variable "metrics_server_chart_repo" {
  type        = string
  default     = "https://kubernetes-sigs.github.io/metrics-server"
  description = "metrics_server_chart_repo"
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

variable "metrics_server_replicas" {
  type        = string
  description = "metrics_server_replicas"
  default     = "1"
}

locals {
  grafana_crd_version_tag             = "v5.20.0"
  prometheus_crd_version              = "8.0.1"
  opentelemetry_chart_version         = "0.93.1"
  grafana_wildcard_gateway            = var.grafana_ingress_internal_lb ? "internal" : "external"
  loki_release_name                   = "loki"
  namespaces_to_central_loki          = "mojaloop"
  prometheus_operator_release_name    = "prom"
  loki_chart_version                  = "6.45.2"
  prometheus_operator_version         = "8.22.8"
  prometheus_process_exporter_version = "0.4.2"
  process_exporter_enabled            = false
  metrics_server_chart_version        = "3.12.2"
  grafana_version                     = "11.6.1"
  grafana_dashboard_tag               = "v16.3.0-snapshot.17"     # NOTE: only for those dashboards which are in mojaloop/helm repo
  grafana_dashboard_tag_iac_modules   = "feature/storage-cluster" # tag for dashboards in mojaloop/iac-modules repo
  grafana_operator_version            = "v5.20.0"
  monitoring_template_path            = "${path.module}/../generate-files/templates/monitoring"
  monitoring_app_file                 = "monitoring-app.yaml"
  loki_ingester_pvc_size              = "10Gi"
  prometheus_pvc_size                 = "50Gi"
  loki_ingester_retention_period      = "72h"
  loki_ingester_max_chunk_age         = "2h"
  loki_ingester_replication_factor    = "3"
  loki_distributor_replica_count      = "2"
  loki_ingester_replica_count         = "3"
  loki_querier_replica_count          = "1"
  loki_distributor_requests_cpu           = "100m"
  loki_distributor_requests_memory        = "128Mi"
  loki_distributor_limits_cpu             = "150m"
  loki_distributor_limits_memory          = "192Mi"
  loki_ingester_requests_cpu              = "100m"
  loki_ingester_requests_memory           = "256Mi"
  loki_ingester_limits_cpu                = "500m"
  loki_ingester_limits_memory             = "1Gi"
  loki_querier_limits_cpu                 = "500m"
  loki_querier_limits_memory              = "192Mi"
  loki_query_frontend_limits_cpu          = "150m"
  loki_query_frontend_limits_memory       = "192Mi"
  loki_query_scheduler_limits_cpu         = "150m"
  loki_query_scheduler_limits_memory      = "192Mi"
  loki_compactor_limits_cpu               = "150m"
  loki_compactor_limits_memory            = "192Mi"
  prometheus_scrape_interval              = "5m"
  prometheus_rate_interval                = "15m"
  prometheus_retention_period             = "10d"
  tempo_retention_period                  = "72h"
  prom_tsdb_min_block_duration            = "30m"
  prom_tsdb_max_block_duration            = "30m"
  grafana_public_fqdn                     = "grafana.${var.public_subdomain}"
  grafana_private_fqdn                    = "grafana.${var.private_subdomain}"
  grafana_subdomain                       = local.grafana_wildcard_gateway == "external" ? var.public_subdomain : var.private_subdomain
  grafana_fqdn                            = local.grafana_wildcard_gateway == "external" ? "grafana.${var.public_subdomain}" : "grafana.${var.private_subdomain}"
  grafana_istio_gateway_namespace         = local.grafana_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  grafana_istio_wildcard_gateway_name     = local.grafana_wildcard_gateway == "external" ? local.istio_external_wildcard_gateway_name : local.istio_internal_wildcard_gateway_name
  enable_central_observability_write      = false
  enable_central_observability_read       = false
  central_observability_tenant_id         = "infitx"
  enable_central_loki_write               = false
  loki_canary_chart_version               = "0.14.0"
  alloy_limits_memory                     = "1Gi"
  alloy_limits_cpu                        = "1000m"
  alertmanager_fqdn                       = "alertmanager.${var.private_subdomain}"
  alertmanager_prod_alerts_enabled        = try(var.common_var_map.alertmanager_prod_alerts_enabled, false)
  alertmanager_slack_external_secret_name = local.alertmanager_prod_alerts_enabled ? "slack-prod-alert-notifications" : "slack-dev-alert-notifications"
  alerts = {
    kafka_consumergroup_lag_threshold      = 20
    kafka_consumergroup_lag_deriv_interval = "10m"
  }

  loki_canary_repo_override = try(var.common_var_map.loki_canary_repo, var.loki_canary_repo)
  prometheus_crd_repo_override = try(var.common_var_map.prometheus_crd_repo, var.prometheus_crd_repo)
  opentelemetry_repo_override = try(var.common_var_map.opentelemetry_chart_repo, var.opentelemetry_chart_repo)
  alloy_repo_override = try(var.common_var_map.alloy_chart_repo, var.alloy_chart_repo)
  metrics_server_chart_repo_override = try(var.common_var_map.metrics_server_chart_repo, var.metrics_server_chart_repo)
  grafana_chart_repo_override = try(var.common_var_map.grafana_chart_repo, var.grafana_chart_repo)
  prometheus_operator_repo_override = try(var.common_var_map.prometheus_operator_repo, var.prometheus_operator_repo)
  loki_repo_override = try(var.common_var_map.loki_repo, var.loki_repo)
  grafana_operator_repo_override = try(var.common_var_map.grafana_operator_repo, var.grafana_operator_repo)

  loki_canary_repo = startswith(local.loki_canary_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.loki_canary_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.loki_canary_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.loki_canary_repo_override)[1]}", local.loki_canary_repo_override) : try(local.helm_proxy_repos_map[local.loki_canary_repo_override], local.loki_canary_repo_override)
  prometheus_crd_repo = startswith(local.prometheus_crd_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.prometheus_crd_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.prometheus_crd_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.prometheus_crd_repo_override)[1]}", local.prometheus_crd_repo_override) : try(local.helm_proxy_repos_map[local.prometheus_crd_repo_override], local.prometheus_crd_repo_override)
  opentelemetry_repo = startswith(local.opentelemetry_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.opentelemetry_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.opentelemetry_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.opentelemetry_repo_override)[1]}", local.opentelemetry_repo_override) : try(local.helm_proxy_repos_map[local.opentelemetry_repo_override], local.opentelemetry_repo_override)
  alloy_repo = startswith(local.alloy_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.alloy_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.alloy_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.alloy_repo_override)[1]}", local.alloy_repo_override) : try(local.helm_proxy_repos_map[local.alloy_repo_override], local.alloy_repo_override)
  metrics_server_chart_repo = startswith(local.metrics_server_chart_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.metrics_server_chart_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.metrics_server_chart_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.metrics_server_chart_repo_override)[1]}", local.metrics_server_chart_repo_override) : try(local.helm_proxy_repos_map[local.metrics_server_chart_repo_override], local.metrics_server_chart_repo_override)
  grafana_chart_repo = startswith(local.grafana_chart_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.grafana_chart_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.grafana_chart_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.grafana_chart_repo_override)[1]}", local.grafana_chart_repo_override) : try(local.helm_proxy_repos_map[local.grafana_chart_repo_override], local.grafana_chart_repo_override)
  prometheus_operator_repo = startswith(local.prometheus_operator_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.prometheus_operator_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", local.prometheus_operator_repo_override)[0]]}${regex("(oci://[^/]+)(.*)", local.prometheus_operator_repo_override)[1]}", local.prometheus_operator_repo_override) : try(local.helm_proxy_repos_map[local.prometheus_operator_repo_override], local.prometheus_operator_repo_override)
  loki_repo = startswith(local.loki_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)",  local.loki_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)",  local.loki_repo_override)[0]]}${regex("(oci://[^/]+)(.*)",  local.loki_repo_override)[1]}",  local.loki_repo_override) : try(local.helm_proxy_repos_map[ local.loki_repo_override],  local.loki_repo_override)
  grafana_operator_repo = startswith(local.grafana_operator_repo_override, "oci://") && can(regex("(oci://[^/]+)(.*)", local.grafana_operator_repo_override)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)",  local.grafana_operator_repo_override)[0]]}${regex("(oci://[^/]+)(.*)",  local.grafana_operator_repo_override)[1]}",  local.grafana_operator_repo_override) : try(local.helm_proxy_repos_map[ local.grafana_operator_repo_override],  local.grafana_operator_repo_override)
}
