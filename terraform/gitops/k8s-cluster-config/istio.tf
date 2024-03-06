module "generate_istio_files" {
  source = "../generate-files"
  var_map = {
    istio_namespace                      = var.istio_namespace
    gitlab_project_url                   = var.gitlab_project_url
    istio_sync_wave                      = var.istio_sync_wave
    istio_chart_repo                     = var.istio_chart_repo
    istio_chart_version                  = var.common_var_map.istio_chart_version
    gateway_api_version                  = var.gateway_api_version
    istio_create_ingress_gateways        = var.istio_create_ingress_gateways
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    istio_egress_gateway_namespace       = local.istio_egress_gateway_namespace
    istio_egress_gateway_name            = local.istio_egress_gateway_name
    istio_egress_gateway_max_replicas    = try(var.common_var_map.istio_egress_gateway_max_replicas,var.istio_egress_gateway_max_replicas)
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
    internal_load_balancer_dns           = var.internal_load_balancer_dns
    external_load_balancer_dns           = var.external_load_balancer_dns
    internal_gateway_hosts               = local.internal_gateway_hosts
    external_gateway_hosts               = local.external_gateway_hosts
    ory_stack_enabled                    = var.ory_stack_enabled
    oathkeeper_auth_url                  = var.ory_stack_enabled ? local.oathkeeper_auth_url : ""
    oathkeeper_auth_provider_name        = var.ory_stack_enabled ? local.oathkeeper_auth_provider_name : ""
    argocd_wildcard_gateway              = local.argocd_wildcard_gateway
    argocd_fqdn                          = local.argocd_fqdn
    argocd_namespace                     = var.argocd_namespace
  }

  file_list       = [for f in fileset(local.istio_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.istio_app_file, f))]
  template_path   = local.istio_template_path
  output_path     = "${var.output_dir}/istio"
  app_file        = local.istio_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  istio_template_path = "${path.module}/../generate-files/templates/istio"
  istio_app_file      = "istio-app.yaml"
}


variable "istio_chart_repo" {
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
  description = "istio_chart_repo"
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

variable "istio_egress_gateway_max_replicas" {
  type        = number
  description = "istio_egress_gateway_max_replicas"
  default     = 5  
}

locals {
  istio_internal_wildcard_gateway_name = "internal-wildcard-gateway"
  istio_external_wildcard_gateway_name = "external-wildcard-gateway"
  istio_egress_gateway_name            = "callback-egress-gateway"
  istio_egress_gateway_namespace       = "egress-gateway"
}
