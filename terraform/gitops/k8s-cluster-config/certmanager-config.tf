module "generate_certman_files" {
  source          = "../generate-files"
  var_map = {
    letsencrypt_server                           = var.letsencrypt_server
    letsencrypt_email                            = var.letsencrypt_email
    cloud_region                                 = var.dns_cloud_region
    public_domain                                = var.public_subdomain
    external_secret_sync_wave                    = var.external_secret_sync_wave
    cert_manager_sync_wave                       = var.cert_manager_sync_wave
    cert_manager_issuer_sync_wave                = var.cert_manager_issuer_sync_wave
    cert_manager_credentials_secret              = "route53-cert-man-credentials"
    cert_manager_chart_repo                      = var.cert_manager_chart_repo
    cert_manager_chart_version                   = var.common_var_map.cert_manager_chart_version
    cert_manager_credentials_id_provider_key     = "${var.cluster_name}/${local.cert_manager_credentials_id_provider_key}"
    cert_manager_credentials_secret_provider_key = "${var.cluster_name}/${local.cert_manager_credentials_secret_provider_key}"
    cert_manager_namespace                       = var.cert_manager_namespace
    gitlab_project_url                           = var.gitlab_project_url
    cert_manager_service_account_name            = var.cert_manager_service_account_name
    cert_manager_credentials_client_secret_name  = local.cert_manager_credentials_client_secret_name
    cert_manager_credentials_client_id_name      = local.cert_manager_credentials_client_id_name
    dns_provider                                 = var.dns_provider
  }
  file_list       = [for f in fileset(local.certman_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.certman_app_file, f))]
  template_path   = local.certman_template_path
  output_path     = "${var.output_dir}/certmanager"
  app_file        = local.certman_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  certman_template_path              = "${path.module}/../generate-files/templates/certmanager"
  certman_app_file                   = "certmanager-app.yaml"
}

variable "cert_manager_chart_repo" {
  type        = string
  description = "cert_manager_chart_repo"
  default     = "https://charts.jetstack.io"
}
variable "cert_manager_namespace" {
  type        = string
  description = "cert_manager_namespace"
  default     = "certmanager"
}

variable "cert_manager_sync_wave" {
  type        = string
  description = "cert_manager_sync_wave"
  default     = "-10"
}

variable "cert_manager_issuer_sync_wave" {
  type        = string
  description = "cert_manager_issuer_sync_wave"
  default     = "-9"
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
