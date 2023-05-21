module "generate_loki_files" {
  source = "./generate-files"
  var_map = {
    loki_chart_repo       = var.loki_chart_repo
    loki_chart_version    = var.loki_chart_version
    gitlab_server_url     = var.gitlab_server_url
    public_subdomain      = var.public_subdomain
    dashboard_namespace   = "monitoring"
    client_id             = var.grafana_oauth_client_id
    client_secret         = var.grafana_oauth_client_secret
    enable_oidc           = var.enable_grafana_oidc
    storage_class_name    = var.storage_class_name
    groups                = var.gitlab_admin_group_name
    prom-mojaloop-url     = "http://loki-stack-prometheus-server"
    admin_secret_pw_key   = "admin-pw"
    admin_secret_user_key = "admin-user"
    admin_secret          = "grafana-admin-secret"
    admin_user_name       = "grafana-admin"
    loki_sync_wave        = var.loki_sync_wave
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "external-secrets/extdns-extsecret.yaml"]
  template_path   = "${path.module}/generate-files/templates/loki"
  output_path     = "${var.output_dir}/loki"
  app_file        = "loki-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "enable_grafana_oidc" {
  type    = bool
  default = false
}

variable "grafana_oauth_client_id" {
  type        = string
  default     = ""
  description = "grafana_oauth_client_id"
}

variable "grafana_oauth_client_secret" {
  type        = string
  default     = ""
  description = "grafana_oauth_client_secret"
  sensitive   = true
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
  default     = "-4"
}
