module "generate_istio_files" {
  source = "./generate-files"
  var_map = {
    istio_namespace                  = var.istio_namespace
    gitlab_project_url               = var.gitlab_project_url
    istio_sync_wave                  = var.istio_sync_wave
    istio_chart_repo                 = var.istio_chart_repo
    istio_chart_version              = var.istio_chart_version
    gateway_api_version              = var.gateway_api_version
    istio_create_ingress_gateways    = var.istio_create_ingress_gateways
    istio_internal_gateway_namespace = var.istio_internal_gateway_namespace
    istio_external_gateway_namespace = var.istio_external_gateway_namespace
    external_ingress_https_port      = var.external_ingress_https_port
    external_ingress_http_port       = var.external_ingress_http_port
    external_ingress_health_port     = var.external_ingress_health_port
    internal_ingress_https_port      = var.internal_ingress_https_port
    internal_ingress_http_port       = var.internal_ingress_http_port
    internal_ingress_health_port     = var.internal_ingress_health_port
    istio_external_gateway_name      = var.istio_external_gateway_name
    istio_internal_gateway_name      = var.istio_internal_gateway_name
  }
  file_list       = ["kustomization.yaml", "namespace.yaml", "values-istio-base.yaml", "values-istio-istiod.yaml", "values-istio-external-ingress-gateway.yaml", "values-istio-internal-ingress-gateway.yaml", "lets-wildcard-cert.yaml"]
  template_path   = "${path.module}/generate-files/templates/istio"
  output_path     = "${var.output_dir}/istio"
  app_file        = "istio-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}


variable "istio_chart_repo" {
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
  description = "istio_chart_repo"
}

variable "istio_chart_version" {
  type        = string
  default     = "1.18.2"
  description = "istio_chart_version"
}

variable "gateway_api_version" {
  type        = string
  default     = "v0.7.1"
  description = "gateway_api_version"
}

variable "istio_sync_wave" {
  type        = string
  description = "istio_sync_wave"
  default     = "-8"
}

variable "istio_namespace" {
  type        = string
  description = "istio_namespace"
  default     = "istio-system"
}

variable "istio_internal_gateway_namespace" {
  type        = string
  description = "istio_internal_gateway_namespace"
  default     = "istio-ingress-int"
}

variable "istio_external_gateway_namespace" {
  type        = string
  description = "istio_external_gateway_namespace"
  default     = "istio-ingress-ext"
}

variable "istio_internal_gateway_name" {
  type        = string
  description = "istio_internal_gateway_name"
  default     = "istio-internal-ingress-gw"
}

variable "istio_external_gateway_name" {
  type        = string
  description = "istio_external_gateway_name"
  default     = "istio-external-ingress-gw"
}

variable "istio_create_ingress_gateways" {
  type        = bool
  description = "should istio create ingress gateways"
  default     = true
}
