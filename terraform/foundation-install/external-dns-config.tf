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
    gitops_project_path_prefix                   = var.gitops_project_path_prefix
    gitlab_project_url                           = var.gitlab_project_url
    external_secret_sync_wave                    = var.external_secret_sync_wave
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "external-secrets/extdns-extsecret.yaml"]
  template_path   = "${path.module}/generate-files/templates/external-dns"
  output_path     = "${var.output_dir}/external-dns"
  app_file        = "external-dns-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}