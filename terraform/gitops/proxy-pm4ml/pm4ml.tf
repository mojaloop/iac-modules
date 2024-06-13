module "generate_pm4ml_files" {
  for_each = var.app_var_map
  source   = "../generate-files"
  var_map = {
    pm4ml_enabled                                   = each.value.pm4ml_enabled
    gitlab_project_url                              = var.gitlab_project_url
    proxy_pm4ml_chart_repo                          = var.proxy_pm4ml_chart_repo
    pm4ml_release_name                              = each.key
    pm4ml_namespace                                 = each.key
    storage_class_name                              = var.storage_class_name
    pm4ml_sync_wave                                 = var.pm4ml_sync_wave + index(keys(var.app_var_map), each.key)
    external_load_balancer_dns                      = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name            = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace                = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name            = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace                = var.istio_external_gateway_namespace
    pm4ml_wildcard_gateway                          = each.value.pm4ml_ingress_internal_lb ? "internal" : "external"
    proxy_id                                        = each.value.pm4ml_proxy_id
    pm4ml_service_account_name                      = "${var.pm4ml_service_account_name}-${each.key}"
    scheme_a_config                                 = each.value.pm4ml_scheme_a_config
    scheme_b_config                                 = each.value.pm4ml_scheme_b_config
    server_cert_secret_namespace                    = each.key
    server_cert_secret_name                         = var.vault_certman_secretname
    vault_certman_secretname                        = var.vault_certman_secretname
    vault_pki_mount                                 = var.vault_root_ca_name
    vault_pki_client_role                           = var.pki_client_cert_role
    vault_pki_server_role                           = var.pki_server_cert_role
    vault_endpoint                                  = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pm4ml_vault_k8s_role_name                       = "${var.pm4ml_vault_k8s_role_name}-${each.key}"
    k8s_auth_path                                   = var.k8s_auth_path
    pm4ml_secret_path                               = "${var.local_vault_kv_root_path}/${each.key}"
    callback_url_scheme_a                           = "https://${local.inter_scheme_proxy_adapter_a_fqdns[each.key]}"
    callback_url_scheme_b                           = "https://${local.inter_scheme_proxy_adapter_b_fqdns[each.key]}"
    inter_scheme_proxy_adapter_a_fqdn               = local.inter_scheme_proxy_adapter_a_fqdns[each.key]
    inter_scheme_proxy_adapter_b_fqdn               = local.inter_scheme_proxy_adapter_b_fqdns[each.key]
    callback_fqdn_scheme_a                          = local.inter_scheme_proxy_adapter_a_fqdns[each.key]
    callback_fqdn_scheme_b                          = local.inter_scheme_proxy_adapter_b_fqdns[each.key]
    nat_ip_list                                     = local.nat_cidr_list
    proxy_pm4ml_chart_version                       = each.value.proxy_pm4ml_chart_version
    pm4ml_external_switch_a_client_secret           = var.pm4ml_external_switch_a_client_secret
    pm4ml_external_switch_b_client_secret           = var.pm4ml_external_switch_b_client_secret
    pm4ml_external_switch_client_secret_key         = "token"
    pm4ml_external_switch_a_client_secret_vault_key = "${var.kv_path}/${var.cluster_name}/${each.key}/${each.value.pm4ml_scheme_a_config.pm4ml_external_switch_client_secret_vault_path}"
    pm4ml_external_switch_b_client_secret_vault_key = "${var.kv_path}/${var.cluster_name}/${each.key}/${each.value.pm4ml_scheme_b_config.pm4ml_external_switch_client_secret_vault_path}"
    pm4ml_external_switch_client_secret_vault_value = "value"
    istio_external_gateway_name                     = var.istio_external_gateway_name
    cert_man_vault_cluster_issuer_name              = var.cert_man_vault_cluster_issuer_name
    ttk_enabled                                     = each.value.pm4ml_ttk_enabled
    ttk_backend_fqdn                                = local.pm4ml_ttk_backend_fqdns[each.key]
    ttk_frontend_fqdn                               = local.pm4ml_ttk_frontend_fqdns[each.key]
    istio_create_ingress_gateways                   = var.istio_create_ingress_gateways
    pm4ml_istio_gateway_namespace                   = local.pm4ml_istio_gateway_namespaces[each.key]
    pm4ml_istio_wildcard_gateway_name               = local.pm4ml_istio_wildcard_gateway_names[each.key]
    pm4ml_istio_gateway_name                        = local.pm4ml_istio_gateway_names[each.key]

  }

  file_list       = [for f in fileset(local.pm4ml_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.pm4ml_app_file, f))]
  template_path   = local.pm4ml_template_path
  output_path     = "${var.output_dir}/${each.key}"
  app_file        = local.pm4ml_app_file
  app_file_prefix = each.key
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  pm4ml_template_path = "${path.module}/../generate-files/templates/proxy-pm4ml"
  pm4ml_app_file      = "proxy-pm4ml-app.yaml"

  pm4ml_var_map = var.app_var_map

  pm4ml_wildcard_gateways = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => pm4ml.pm4ml_ingress_internal_lb ? "internal" : "external" }
  
  inter_scheme_proxy_adapter_a_fqdns = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? "conn-a-${pm4ml.pm4ml}.${var.public_subdomain}" : "conn-${pm4ml.pm4ml}.${var.private_subdomain}" }
  inter_scheme_proxy_adapter_b_fqdns = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? "conn-b-${pm4ml.pm4ml}.${var.public_subdomain}" : "conn-${pm4ml.pm4ml}.${var.private_subdomain}" }
  pm4ml_ttk_frontend_fqdns  = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? "ttkfront-${pm4ml.pm4ml}.${var.public_subdomain}" : "ttkfront-${pm4ml.pm4ml}.${var.private_subdomain}" }
  pm4ml_ttk_backend_fqdns   = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? "ttkback-${pm4ml.pm4ml}.${var.public_subdomain}" : "ttkback-${pm4ml.pm4ml}.${var.private_subdomain}"}

  pm4ml_istio_gateway_namespaces     = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace }
  pm4ml_istio_wildcard_gateway_names = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? var.istio_external_wildcard_gateway_name : var.istio_internal_wildcard_gateway_name }
  pm4ml_istio_gateway_names          = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external" ? var.istio_external_gateway_name : var.istio_internal_gateway_name }

}


variable "app_var_map" {
  type = any
}

variable "pm4ml_vault_k8s_role_name" {
  description = "vault k8s role name for pm4ml"
  type        = string
  default     = "kubernetes-pm4ml-role"
}

variable "pm4ml_ingress_internal_lb" {
  type        = bool
  description = "pm4ml_ingress_internal_lb"
  default     = true
}

variable "proxy_pm4ml_chart_repo" {
  description = "repo for proxy pm4ml charts"
  type        = string
  default     = "https://pm4ml.github.io/mojaloop-payment-manager-helm/repo"
}

variable "pm4ml_sync_wave" {
  type        = number
  description = "pm4ml_sync_wave"
  default     = 0
}


variable "pm4ml_service_account_name" {
  type        = string
  description = "service account name for pm4ml"
  default     = "pm4ml"
}

variable "pm4ml_external_switch_a_client_secret" {
  type        = string
  description = "secret name for client secret to connect to switch-a idm"
  default     = "pm4ml-external-switch-a-client-secret"
}

variable "pm4ml_external_switch_b_client_secret" {
  type        = string
  description = "secret name for client secret to connect to switch-b idm"
  default     = "pm4ml-external-switch-b-client-secret"
}

locals {
  nat_cidr_list = join(", ", [for ip in var.nat_public_ips : format("%s/32", ip)])
}
