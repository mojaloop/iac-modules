module "generate_istio_files" {
  source = "./generate-files"
  var_map = {
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
  file_list = ["charts/istio/Chart.yaml", "charts/istio/values.yaml", "lets-wildcard-cert.yaml", "gateway-api-kustomization.yaml"]
  template_path   = "${path.module}/generate-files/templates/istio"
  output_path     = "${var.output_dir}/istio"
  app_file        = "istio-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "istio_helm_chart_repo" {
  type        = string
  description = "istio_helm_chart_repo"
  default     = "https://istio-release.storage.googleapis.com/charts"
}
variable "istio_helm_chart_version" {
  type        = string
  description = "istio_helm_chart_version"
  default     = "1.18.0"
}
variable "istio_namespace" {
  type        = string
  description = "istio_namespace"
  default     = "istio-system"
}
variable "istio_sync_wave" {
  type        = string
  description = "istio_sync_wave"
  default     = "-8"
}

variable "internal_ingress_class_name" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "istio-int"
}
variable "external_ingress_class_name" {
  type        = string
  description = "external_ingress_class_name"
  default     = "istio-ext"
}
variable "internal_ingress_https_port" {
  type        = number
  description = "internal_ingress_https_port"
  default     = 31443
}
variable "internal_ingress_http_port" {
  type        = number
  description = "internal_ingress_http_port"
  default     = 31080
}
variable "external_ingress_https_port" {
  type        = number
  description = "external_ingress_https_port"
  default     = 32443
}
variable "external_ingress_http_port" {
  type        = number
  description = "external_ingress_http_port"
  default     = 32080
}
