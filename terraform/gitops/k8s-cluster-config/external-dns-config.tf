module "generate_extdns_files" {
  source = "../generate-files"
  var_map = {
    external_dns_chart_repo                      = var.external_dns_chart_repo
    external_dns_chart_version                   = var.common_var_map.external_dns_chart_version
    external_dns_credentials_secret              = "route53-external-dns-credentials"
    dns_cloud_region                             = var.dns_cloud_region
    text_owner_id                                = var.cluster_name
    public_subdomain                             = var.public_subdomain
    private_subdomain                            = var.private_subdomain
    external_dns_credentials_id_provider_key     = "${var.cluster_name}/${local.external_dns_credentials_id_provider_key}"
    external_dns_credentials_secret_provider_key = "${var.cluster_name}/${local.external_dns_credentials_secret_provider_key}"
    external_dns_namespace                       = var.external_dns_namespace
    gitlab_project_url                           = var.gitlab_project_url
    external_secret_sync_wave                    = var.external_secret_sync_wave
    external_dns_sync_wave                       = var.external_dns_sync_wave
    external_dns_credentials_client_secret_name  = local.external_dns_credentials_client_secret_name
    external_dns_credentials_client_id_name      = local.external_dns_credentials_client_id_name
    dns_provider                                 = var.dns_provider
  }
  file_list       = [for f in fileset(local.extdns_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.extdns_app_file, f))]
  template_path   = local.extdns_template_path
  output_path     = "${var.output_dir}/external-dns"
  app_file        = local.extdns_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  extdns_template_path              = "${path.module}/../generate-files/templates/external-dns"
  extdns_app_file                   = "external-dns-app.yaml"
}
variable "external_dns_chart_repo" {
  type        = string
  description = "external_dns_chart_repo"
  default     = "https://charts.bitnami.com/bitnami"
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

variable "external_dns_sync_wave" {
  type        = string
  description = "external_dns_sync_wave"
  default     = "-8"
}