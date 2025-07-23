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
    kiali_chart_version                  = var.kiali_chart_version
    kiali_chart_repo                     = var.kiali_chart_repo
    kiali_fqdn                           = local.kiali_fqdn
    kiali_istio_wildcard_gateway_name    = local.kiali_istio_wildcard_gateway_name
    kiali_istio_gateway_namespace        = local.kiali_istio_gateway_namespace
    kiali_sync_wave                      = var.kiali_sync_wave
    # Netbird egress gateway variables
    istio_egress_gateway_name            = local.istio_egress_gateway_name
    istio_egress_gateway_namespace       = local.istio_egress_gateway_namespace
    netbird_version                      = try(var.common_var_map.netbird_image_version, "0.51.1")
    netbird_management_url               = var.netbird_management_url
    netbird_setup_key_secret_name        = local.netbird_setup_key_secret_name
    netbird_setup_key_secret_key         = local.netbird_setup_key_secret_key
    netbird_setup_key_vault_path         = var.netbird_setup_key_vault_path
    external_secret_sync_wave            = var.external_secret_sync_wave
    # Internal domain configuration for egress routing
    internal_wildcard_hosts              = local.internal_wildcard_hosts_list
    internal_non_https_ports             = local.internal_non_https_ports_list
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
  # Netbird egress gateway configuration
  istio_egress_gateway_name            = "istio-netbird-egress-gw"
  istio_egress_gateway_namespace       = "istio-egress-nb"
  # Netbird secret configuration
  netbird_setup_key_secret_name        = "netbird-setup-key"
  netbird_setup_key_secret_key         = "setup-key"
  # Parse comma-delimited strings into lists for Netbird egress routing
  internal_wildcard_hosts_list = split(",", trimspace(var.internal_wildcard_hosts))
  internal_non_https_ports_list = [
    for port_spec in split(",", trimspace(var.internal_non_https_ports)) : {
      number   = tonumber(split(":", port_spec)[0])
      name     = split(":", port_spec)[1]
      protocol = split(":", port_spec)[2]
    }
  ]
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
  default     = "-10"
}

variable "istio_gateways_sync_wave" {
  type        = string
  description = "istio_gateways_sync_wave"
  default     = "-8"
}

variable "kiali_sync_wave" {
  type        = string
  description = "kiali_sync_wave"
  default     = "-7"
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

variable "netbird_management_url" {
  type        = string
  description = "Netbird management server URL"
  default     = "https://api.netbird.io"
}

variable "netbird_setup_key_vault_path" {
  type        = string
  description = "Vault path where the Netbird setup key is stored"
  default     = "kv/data/netbird/setup-key"
}

variable "internal_wildcard_hosts" {
  type        = string
  description = "Comma-delimited list of domain suffixes for internal domain routing (without wildcard prefix)"
  default     = "int.test.com"
}

variable "internal_non_https_ports" {
  type        = string
  description = "Comma-delimited list of non-HTTPS ports for internal domain routing (format: number:name:protocol)"
  default     = "80:http:HTTP,8200:vault-api:HTTP,3000:grafana:HTTP,9090:prometheus:HTTP"
}