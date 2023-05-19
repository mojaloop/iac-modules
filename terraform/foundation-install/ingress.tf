module "generate_ingress_files" {
  source = "./generate-files"
  var_map = {
    gitops_project_path_prefix  = var.gitops_project_path_prefix
    nginx_helm_chart_repo       = var.nginx_helm_chart_repo
    nginx_helm_chart_version    = var.nginx_helm_chart_version
    nginx_external_namespace    = var.nginx_external_namespace
    nginx_internal_namespace    = var.nginx_internal_namespace
    gitlab_project_url          = var.gitlab_project_url
    ingress_sync_wave           = var.ingress_sync_wave
    default_ssl_certificate     = var.default_ssl_certificate
    wildcare_certificate_wave   = var.wildcare_certificate_wave
    public_subdomain            = var.public_subdomain
    internal_ingress_class_name = var.internal_ingress_class_name
    internal_ingress_https_port = var.internal_ingress_https_port
    internal_ingress_http_port  = var.internal_ingress_http_port
    external_ingress_class_name = var.external_ingress_class_name
    external_ingress_https_port = var.external_ingress_https_port
    external_ingress_http_port  = var.external_ingress_http_port
    external_load_balancer_dns  = var.external_load_balancer_dns
    internal_load_balancer_dns  = var.internal_load_balancer_dns
  }
  file_list = ["charts/nginx-external/Chart.yaml", "charts/nginx-external/values.yaml",
    "charts/nginx-internal/Chart.yaml", "charts/nginx-internal/values.yaml",
  "ingress-external.yaml", "ingress-internal.yaml", "lets-wildcard-cert.yaml"]
  template_path   = "${path.module}/generate-files/templates/ingress"
  output_path     = "${var.output_dir}/ingress"
  app_file        = "ingress-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}