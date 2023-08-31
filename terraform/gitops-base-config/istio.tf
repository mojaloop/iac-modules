module "generate_istio_files" {
  source = "./generate-files"
  var_map = {
    istio_namespace                      = var.istio_namespace
    gitlab_project_url                   = var.gitlab_project_url
    istio_sync_wave                      = var.istio_sync_wave
    istio_chart_repo                     = var.istio_chart_repo
    istio_chart_version                  = var.istio_chart_version
    gateway_api_version                  = var.gateway_api_version
    istio_create_ingress_gateways        = var.istio_create_ingress_gateways
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    external_ingress_https_port          = var.external_ingress_https_port
    external_ingress_http_port           = var.external_ingress_http_port
    external_ingress_health_port         = var.external_ingress_health_port
    internal_ingress_https_port          = var.internal_ingress_https_port
    internal_ingress_http_port           = var.internal_ingress_http_port
    internal_ingress_health_port         = var.internal_ingress_health_port
    istio_external_gateway_name          = var.istio_external_gateway_name
    istio_internal_gateway_name          = var.istio_internal_gateway_name
    default_ssl_certificate              = var.default_ssl_certificate
    wildcare_certificate_wave            = var.wildcare_certificate_wave
    public_subdomain                     = var.public_subdomain
    istio_gateways_sync_wave             = var.istio_gateways_sync_wave
    kiali_chart_version                  = var.kiali_chart_version
    kiali_chart_repo                     = var.kiali_chart_repo
    keycloak_wildcard_gateway            = local.keycloak_wildcard_gateway
    mojaloop_wildcard_gateway            = local.mojaloop_wildcard_gateway
    mcm_wildcard_gateway                 = local.mcm_wildcard_gateway
    loki_wildcard_gateway                = local.loki_wildcard_gateway
    vault_wildcard_gateway               = local.vault_wildcard_gateway
    internal_load_balancer_dns           = var.internal_load_balancer_dns
    external_load_balancer_dns           = var.external_load_balancer_dns
    keycloak_fqdn                        = local.keycloak_fqdn
    mcm_public_fqdn                      = local.mcm_public_fqdn
  }
  file_list = ["istio-deploy.yaml",
    "istio-gateways.yaml", "istio-main/kustomization.yaml", "istio-main/namespace.yaml",
    "istio-main/values-kiali.yaml", "istio-main/values-istio-base.yaml", "istio-main/values-istio-istiod.yaml",
    "istio-gateways/kustomization.yaml", "istio-gateways/values-istio-external-ingress-gateway.yaml",
    "istio-gateways/values-istio-internal-ingress-gateway.yaml", "istio-gateways/lets-wildcard-cert.yaml",
    "istio-gateways/namespace.yaml", "istio-gateways/proxy-protocol.yaml", "istio-gateways/gateways.yaml"]
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

variable "kiali_chart_repo" {
  type        = string
  default     = "https://kiali.org/helm-charts"
  description = "kiali_chart_repo"
}

variable "kiali_chart_version" {
  type        = string
  default     = "1.42.0"
  description = "kiali_chart_version"
}

variable "gateway_api_version" {
  type        = string
  default     = "v0.7.1"
  description = "gateway_api_version"
}

variable "istio_sync_wave" {
  type        = string
  description = "istio_sync_wave"
  default     = "-10"
}

variable "istio_gateways_sync_wave" {
  type        = string
  description = "istio_gateways_sync_wave"
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

locals {
  istio_internal_wildcard_gateway_name = "internal-wildcard-gateway"
  istio_external_wildcard_gateway_name = "external-wildcard-gateway"
}
