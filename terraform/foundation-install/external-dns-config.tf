module "generate_extdns_files" {
  source = "./generate-files"
  var_map = {
    external_dns_chart_repo                      = var.external_dns_chart_repo
    external_dns_chart_version                   = var.external_dns_chart_version
    external_dns_credentials_secret              = var.external_dns_credentials_secret
    dns_cloud_region                             = var.dns_cloud_region
    text_owner_id                                = var.cluster_name
    public_subdomain                             = var.public_subdomain
    private_subdomain                            = var.private_subdomain
    external_dns_credentials_id_provider_key     = var.gitlab_key_route53_external_dns_access_key
    external_dns_credentials_secret_provider_key = var.gitlab_key_route53_external_dns_secret_key
    external_dns_namespace                       = var.external_dns_namespace
    gitlab_project_url                           = var.gitlab_project_url
    external_secret_sync_wave                    = var.external_secret_sync_wave
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "external-secrets/extdns-extsecret.yaml"]
  template_path   = "${path.module}/generate-files/templates/external-dns"
  output_path     = "${var.output_dir}/external-dns"
  app_file        = "external-dns-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "external_dns_credentials_secret" {
  type        = string
  description = "external_dns_credentials_secret"
  default     = "route53-external-dns-credentials"
}

variable "gitlab_key_route53_external_dns_access_key" {
  type        = string
  description = "gitlab_key_route53_external_dns_access_key"
}

variable "gitlab_key_route53_external_dns_secret_key" {
  type        = string
  description = "gitlab_key_route53_external_dns_secret_key"
}

variable "external_dns_chart_repo" {
  type        = string
  description = "external_dns_chart_repo"
  default     = "https://charts.bitnami.com/bitnami"
}

variable "external_dns_chart_version" {
  type        = string
  description = "external_dns_chart_version"
  default     = "6.7.2"
}

variable "external_dns_namespace" {
  type        = string
  description = "external_dns_namespace"
  default     = "external-dns"
}

variable "dns_cloud_region" {
  type = string
  description = "cloud region for ext dns"
}