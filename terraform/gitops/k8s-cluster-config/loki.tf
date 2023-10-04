module "generate_loki_files" {
  source = "../generate-files"
  var_map = {
    loki_chart_repo                      = var.loki_chart_repo
    loki_chart_version                   = var.loki_chart_version
    loki_namespace                       = var.loki_namespace
    gitlab_server_url                    = var.gitlab_server_url
    gitlab_project_url                   = var.gitlab_project_url
    public_subdomain                     = var.public_subdomain
    dashboard_namespace                  = "monitoring"
    client_id                            = data.vault_generic_secret.grafana_oauth_client_id.data.value
    client_secret                        = data.vault_generic_secret.grafana_oauth_client_secret.data.value
    enable_oidc                          = var.enable_grafana_oidc
    storage_class_name                   = var.storage_class_name
    groups                               = var.gitlab_admin_group_name
    prom-mojaloop-url                    = "http://loki-app-prometheus-server"
    admin_secret_pw_key                  = "admin-pw"
    admin_secret_user_key                = "admin-user"
    admin_secret                         = "grafana-admin-secret"
    admin_user_name                      = "grafana-admin"
    loki_sync_wave                       = var.loki_sync_wave
    ingress_class                        = var.grafana_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways        = var.istio_create_ingress_gateways
    istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    loki_wildcard_gateway                = local.loki_wildcard_gateway
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "custom-resources/password-policy.yaml", "custom-resources/random-secret.yaml", "custom-resources/vault-secret.yaml", "custom-resources/istio-gateway.yaml"]
  template_path   = "${path.module}/generate-files/templates/loki"
  output_path     = "${var.output_dir}/loki"
  app_file        = "loki-app.yaml"
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

variable "loki_chart_repo" {
  type        = string
  default     = "https://grafana.github.io/helm-charts"
  description = "loki_chart_repo"
}

variable "loki_chart_version" {
  type        = string
  default     = "2.9.10"
  description = "loki_chart_version"
}

variable "loki_sync_wave" {
  type        = string
  description = "loki_sync_wave"
  default     = "-5"
}

variable "loki_namespace" {
  type        = string
  description = "loki_namespace"
  default     = "monitoring"
}

locals {
  loki_wildcard_gateway = var.grafana_ingress_internal_lb ? "internal" : "external"
}
