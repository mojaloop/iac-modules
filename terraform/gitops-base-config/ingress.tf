module "generate_ingress_files" {
  source = "./generate-files"
  var_map = {
    nginx_helm_chart_repo        = var.nginx_helm_chart_repo
    nginx_helm_chart_version     = var.nginx_helm_chart_version
    nginx_jwt_helm_chart_repo    = var.nginx_jwt_helm_chart_repo
    nginx_jwt_helm_chart_version = var.nginx_jwt_helm_chart_version
    gitlab_server_url            = var.gitlab_server_url
    nginx_external_namespace     = var.nginx_external_namespace
    nginx_internal_namespace     = var.nginx_internal_namespace
    nginx_jwt_namespace          = var.nginx_jwt_namespace
    gitlab_project_url           = var.gitlab_project_url
    ingress_sync_wave            = var.ingress_sync_wave
    default_ssl_certificate      = var.default_ssl_certificate
    wildcare_certificate_wave    = var.wildcare_certificate_wave
    public_subdomain             = var.public_subdomain
    internal_ingress_class_name  = var.internal_ingress_class_name
    internal_ingress_https_port  = var.internal_ingress_https_port
    internal_ingress_http_port   = var.internal_ingress_http_port
    external_ingress_class_name  = var.external_ingress_class_name
    external_ingress_https_port  = var.external_ingress_https_port
    external_ingress_http_port   = var.external_ingress_http_port
    external_load_balancer_dns   = var.external_load_balancer_dns
    internal_load_balancer_dns   = var.internal_load_balancer_dns
  }
  file_list = ["charts/nginx-external/Chart.yaml", "charts/nginx-external/values.yaml",
    "charts/nginx-internal/Chart.yaml", "charts/nginx-internal/values.yaml",
    "charts/nginx-jwt/Chart.yaml", "charts/nginx-jwt/values.yaml",
    "ingress-external.yaml", "ingress-internal.yaml", "ingress-jwt.yaml", "lets-wildcard-cert.yaml"]
  template_path   = "${path.module}/generate-files/templates/ingress"
  output_path     = "${var.output_dir}/ingress"
  app_file        = "ingress-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "nginx_helm_chart_repo" {
  type        = string
  description = "nginx_helm_chart_repo"
  default     = "https://kubernetes.github.io/ingress-nginx"
}
variable "nginx_helm_chart_version" {
  type        = string
  description = "nginx_helm_chart_version"
  default     = "4.3.0"
}

variable "nginx_jwt_helm_chart_repo" {
  type        = string
  description = "nginx_jwt_helm_chart_repo"
  default     = "https://ivanjosipovic.github.io/ingress-nginx-validate-jwt"
}
variable "nginx_jwt_helm_chart_version" {
  type        = string
  description = "nginx_jwt_helm_chart_version"
  default     = "1.3.10"
}

variable "nginx_jwt_namespace" {
  type        = string
  description = "nginx_jwt_namespace"
  default     = "nginx-jwt"
}
variable "nginx_external_namespace" {
  type        = string
  description = "nginx_external_namespace"
  default     = "nginx-ext"
}
variable "nginx_internal_namespace" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "ingress_sync_wave" {
  type        = string
  description = "ingress_sync_wave"
  default     = "-7"
}
variable "default_ssl_certificate" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "wildcare_certificate_wave" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "-8"
}
variable "internal_ingress_class_name" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "external_ingress_class_name" {
  type        = string
  description = "external_ingress_class_name"
  default     = "nginx-ext"
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
