module "generate_istio_files" {
  source = "../generate-files"
  var_map = {
    istio_namespace                      = var.istio_namespace
    gitlab_project_url                   = var.gitlab_project_url
    istio_sync_wave                      = var.istio_sync_wave
    istio_chart_repo                     = local.istio_chart_repo
    istio_chart_version                  = var.common_var_map.istio_chart_version
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
    default_internal_ssl_certificate     = var.default_internal_ssl_certificate
    wildcare_certificate_wave            = var.wildcare_certificate_wave
    public_subdomain                     = var.public_subdomain
    private_subdomain                    = var.private_subdomain
    istio_gateways_sync_wave             = var.istio_gateways_sync_wave
    internal_load_balancer_dns           = var.internal_load_balancer_dns
    external_load_balancer_dns           = var.external_load_balancer_dns
    oathkeeper_auth_url                  = local.oathkeeper_auth_url
    oathkeeper_auth_provider_name        = local.oathkeeper_auth_provider_name
    argocd_wildcard_gateway              = local.argocd_wildcard_gateway
    argocd_public_fqdn                   = local.argocd_public_fqdn
    argocd_private_fqdn                  = local.argocd_private_fqdn
    argocd_namespace                     = var.argocd_namespace
    istio_proxy_log_level                = try(var.common_var_map.istio_proxy_log_level, local.istio_proxy_log_level)
    istio_ztunnel_log_level              = try(var.common_var_map.istio_ztunnel_log_level, "warn")
    istio_ztunnel_readiness_timeout      = try(var.common_var_map.istio_ztunnel_readiness_timeout, 5)
    kiali_chart_version                  = var.kiali_chart_version
    kiali_chart_repo                     = local.kiali_chart_repo
    kiali_fqdn                           = local.kiali_fqdn
    kiali_istio_wildcard_gateway_name    = local.kiali_istio_wildcard_gateway_name
    kiali_istio_gateway_namespace        = local.kiali_istio_gateway_namespace
    kiali_sync_wave                      = var.kiali_sync_wave
    # Internal domain configuration for egress routing
    netbird_traffic_hosts  = local.netbird_traffic_hosts_list
    netbird_setup_key_name = var.netbird_setup_key_name
    istio_cni_platform     = var.istio_cni_platform
    istio_nb_egress_waypoint_name        = var.istio_nb_egress_waypoint_name
    istio_nb_egress_waypoint_namespace   = var.istio_nb_egress_waypoint_namespace
    cluster                              = var.app_var_map.cluster
  }

  file_list       = [for f in fileset(local.istio_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.istio_app_file, f))]
  template_path   = local.istio_template_path
  output_path     = "${var.output_dir}/istio"
  app_file        = local.istio_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {

  istio_template_path                  = "${path.module}/../generate-files/templates/istio"
  istio_app_file                       = "istio-app.yaml"
  istio_proxy_log_level                = "warn"
  argocd_wildcard_gateway              = var.argocd_ingress_internal_lb ? "internal" : "external"
  argocd_public_fqdn                   = "argocd.${var.public_subdomain}"
  argocd_private_fqdn                  = "argocd.${var.private_subdomain}"
  istio_internal_wildcard_gateway_name = "internal-wildcard-gateway"
  istio_external_wildcard_gateway_name = "external-wildcard-gateway"
  kiali_istio_wildcard_gateway_name    = local.kiali_wildcard_gateway == "external" ? local.istio_external_wildcard_gateway_name : local.istio_internal_wildcard_gateway_name
  kiali_istio_gateway_namespace        = local.kiali_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  kiali_wildcard_gateway               = var.kiali_ingress_internal_lb ? "internal" : "external"
  kiali_fqdn                           = local.kiali_wildcard_gateway == "external" ? "kiali.${var.public_subdomain}" : "kiali.${var.private_subdomain}"
  # Parse comma-delimited strings into lists for Netbird egress routing
  netbird_traffic_hosts_list = var.netbird_traffic_hosts != "" ? split(",", trimspace(var.netbird_traffic_hosts)) : []
  istio_chart_repo = startswith(var.istio_chart_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.istio_chart_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.istio_chart_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.istio_chart_repo)[1]}", var.istio_chart_repo) : try(local.helm_proxy_repos_map[var.istio_chart_repo], var.istio_chart_repo)
  kiali_chart_repo = startswith(var.kiali_chart_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.kiali_chart_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.kiali_chart_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.kiali_chart_repo)[1]}", var.kiali_chart_repo) : try(local.helm_proxy_repos_map[var.kiali_chart_repo], var.kiali_chart_repo)
}


variable "istio_chart_repo" {
  type        = string
  default     = "oci://gcr.io/istio-release/charts"
  description = "istio_chart_repo"
}

variable "kiali_chart_repo" {
  type        = string
  default     = "https://kiali.org/helm-charts"
  description = "kiali_chart_repo"
}

variable "kiali_chart_version" {
  type        = string
  default     = "2.11.0"
  description = "kiali_chart_version"
}

variable "gateway_api_version" {
  type        = string
  default     = "v1.3.0"
  description = "gateway_api_version"
}

variable "istio_sync_wave" {
  type        = string
  description = "istio_sync_wave"
  default     = "-14"
}

variable "istio_gateways_sync_wave" {
  type        = string
  description = "istio_gateways_sync_wave"
  default     = "-11"
}

variable "kiali_sync_wave" {
  type        = string
  description = "kiali_sync_wave"
  default     = "-10"
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

variable "kiali_ingress_internal_lb" {
  type        = bool
  description = "kiali_ingress_internal_lb"
  default     = true
}

variable "istio_egress_gateway_max_replicas" {
  type        = number
  description = "Maximum number of replicas for the Istio egress gateway"
  default     = 3
}

variable "netbird_traffic_hosts" {
  type        = string
  description = "Comma-delimited list of domain suffixes for internal domain routing (without wildcard prefix)"
  default     = ""
}

variable "istio_cni_platform" {
  type        = string
  description = "CNI platform for Istio"
  default     = "none"
}

variable "istio_nb_egress_waypoint_name" {
  type        = string
  description = "Name of the Istio egress waypoint"
  default     = "nb-egress-waypoint"
}

variable "istio_nb_egress_waypoint_namespace" {
  type        = string
  description = "Namespace of the Istio egress waypoint"
  default     = "istio-system"
}