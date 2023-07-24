module "generate_certman_files" {
  source          = "./generate-files"
  file_list       = ["charts/certman-chart/Chart.yaml", "charts/certman-chart/values.yaml", "certman-chart.yaml", "reflector.yaml", "lets-cluster-issuer.yaml", "certman-extsecret.yaml", "charts/reflector/Chart.yaml", "charts/reflector/values.yaml"]
  template_path   = "${path.module}/generate-files/templates/certmanager"
  output_path     = "${var.output_dir}/certmanager"
  app_file        = "certmanager-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
  var_map = {
    letsencrypt_server                           = var.letsencrypt_server
    letsencrypt_email                            = var.letsencrypt_email
    cert_manager_issuer_sync_wave                = var.cert_manager_issuer_sync_wave
    cloud_region                                 = var.dns_cloud_region
    public_domain                                = var.public_subdomain
    external_secret_sync_wave                    = var.external_secret_sync_wave
    cert_manager_credentials_secret              = "route53-cert-man-credentials"
    cert_manager_chart_repo                      = var.cert_manager_chart_repo
    cert_manager_chart_version                   = var.cert_manager_chart_version
    cert_manager_credentials_id_provider_key     = "${var.cluster_name}/${local.cert_manager_credentials_id_provider_key}"
    cert_manager_credentials_secret_provider_key = "${var.cluster_name}/${local.cert_manager_credentials_secret_provider_key}"
    cert_manager_namespace                       = var.cert_manager_namespace
    gitlab_project_url                           = var.gitlab_project_url
    cert_manager_service_account_name            = var.cert_manager_service_account_name
    reflector_chart_repo                         = var.reflector_chart_repo
    reflector_chart_version                      = var.reflector_chart_version
    reflector_namespace                          = var.reflector_namespace
  }
}

variable "cert_manager_chart_repo" {
  type        = string
  description = "cert_manager_chart_repo"
  default     = "https://charts.jetstack.io"
}
variable "cert_manager_chart_version" {
  type        = string
  description = "1.11.0"
}

variable "cert_manager_namespace" {
  type        = string
  description = "cert_manager_namespace"
  default     = "certmanager"
}

variable "reflector_chart_repo" {
  type        = string
  description = "reflector_chart_repo"
  default     = "https://emberstack.github.io/helm-charts"
}
variable "reflector_chart_version" {
  type        = string
  description = "reflector_chart_version"
  default = "7.0.190"
}

variable "reflector_namespace" {
  type        = string
  description = "reflector_namespace"
  default     = "reflector"
}

variable "cert_manager_issuer_sync_wave" {
  type        = string
  description = "cert_manager_issuer_sync_wave"
  default     = "-10"
}

variable "letsencrypt_server" {
  type        = string
  description = "letsencrypt_server"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "letsencrypt_email" {
  type        = string
  description = "letsencrypt_email"
  default     = "cicd@example.com"
}

variable "cert_manager_service_account_name" {
  type        = string
  description = "service account to run cert man"
  default     = "cert-man-sa"
}
