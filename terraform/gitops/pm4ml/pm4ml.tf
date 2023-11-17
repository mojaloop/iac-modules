module "generate_pm4ml_files" {
  for_each = var.app_var_map
  source = "../generate-files"
  var_map = {
    pm4ml_enabled                                   = each.value.pm4ml_enabled
    gitlab_project_url                              = var.gitlab_project_url
    pm4ml_chart_repo                                = var.pm4ml_chart_repo
    pm4ml_release_name                              = each.key
    pm4ml_namespace                                 = each.key
    storage_class_name                              = var.storage_class_name
    pm4ml_sync_wave                                 = var.pm4ml_sync_wave
    external_load_balancer_dns                      = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name            = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace                = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name            = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace                = var.istio_external_gateway_namespace
    pm4ml_wildcard_gateway                          = each.value.pm4ml_wildcard_gateway
    keycloak_fqdn                                   = var.keycloak_fqdn
    keycloak_pm4ml_realm_name                       = "${var.keycloak_pm4ml_realm_name}-${each.key}"
    experience_api_fqdn                             = var.experience_api_fqdns[each.key]
    portal_fqdn                                     = var.portal_fqdns[each.key]
    dfsp_id                                         = each.value.dfsp_id
    pm4ml_service_account_name                      = var.pm4ml_service_account_name
    mcm_host_url                                    = "https://${var.app_var_map[each.key].pm4ml_external_mcm_public_fqdn}"
    server_cert_secret_namespace                    = each.key
    server_cert_secret_name                         = var.vault_certman_secretname
    vault_certman_secretname                        = var.vault_certman_secretname
    vault_pki_mount                                 = var.vault_root_ca_name
    vault_pki_client_role                           = var.pki_client_cert_role
    vault_pki_server_role                           = var.pki_server_cert_role
    vault_k8s_role                                  = var.pm4ml_vault_k8s_role_name
    vault_endpoint                                  = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pm4ml_vault_k8s_role_name                       = var.pm4ml_vault_k8s_role_name
    k8s_auth_path                                   = var.k8s_auth_path
    pm4ml_secret_path                               = "${var.local_vault_kv_root_path}/${each.key}"
    callback_url                                    = "https://${var.mojaloop_connnector_fqdns[each.key]}"
    mojaloop_connnector_fqdn                        = var.mojaloop_connnector_fqdns[each.key]
    callback_fqdn                                   = var.mojaloop_connnector_fqdns[each.key]
    redis_port                                      = "6379"
    redis_host                                      = "redis-master"
    redis_replica_count                             = "1"
    nat_ip_list                                     = local.nat_cidr_list
    pm4ml_oidc_client_id                            = "${var.pm4ml_oidc_client_id_prefix}-${each.key}"
    pm4ml_oidc_client_secret_secret_name            = join("$", ["", "{${replace("${var.pm4ml_oidc_client_secret_secret_prefix}-${each.key}", "-", "_")}}"])
    pm4ml_oidc_client_secret_secret                 = "${var.pm4ml_oidc_client_secret_secret_prefix}-${each.key}"
    pm4ml_oidc_client_secret_secret_key             = var.pm4ml_oidc_client_secret_secret_key
    keycloak_namespace                              = var.keycloak_namespace
    keycloak_name                                   = var.keycloak_name
    pm4ml_external_switch_fqdn                      = var.app_var_map[each.key].pm4ml_external_switch_fqdn
    pm4ml_chart_version                             = var.app_var_map[each.key].pm4ml_chart_version
    pm4ml_external_switch_client_id                 = var.app_var_map[each.key].pm4ml_external_switch_client_id
    pm4ml_external_switch_oidc_url                  = var.app_var_map[each.key].pm4ml_external_switch_oidc_url
    pm4ml_external_switch_oidc_token_route          = var.app_var_map[each.key].pm4ml_external_switch_oidc_token_route
    pm4ml_external_switch_client_secret             = var.pm4ml_external_switch_client_secret
    pm4ml_external_switch_client_secret_key         = "token"
    pm4ml_external_switch_client_secret_vault_key   = "${var.kv_path}/${var.cluster_name}/${each.key}/${var.app_var_map[each.key].pm4ml_external_switch_client_secret_vault_path}"
    pm4ml_external_switch_client_secret_vault_value = "value"
    istio_external_gateway_name                     = var.istio_external_gateway_name
    cert_man_vault_cluster_issuer_name              = var.cert_man_vault_cluster_issuer_name
    enable_sdk_bulk_transaction_support             = var.app_var_map[each.key].enable_sdk_bulk_transaction_support
    kafka_host                                      = "kafka"
    kafka_port                                      = "9092"
    ttk_enabled                                     = var.app_var_map[each.key].pm4ml_ttk_enabled
    use_ttk_as_backend_simulator                    = var.app_var_map[each.key].use_ttk_as_backend_simulator
    ttk_backend_fqdn                                = var.ttk_backend_fqdns[each.key]
    ttk_frontend_fqdn                               = var.ttk_frontend_fqdns[each.key]
    test_fqdn                                       = var.test_fqdns[each.key]
  }
  file_list       = ["istio-gateway.yaml", "keycloak-realm-cr.yaml", "kustomization.yaml", "values-pm4ml.yaml", "vault-secret.yaml", "vault-certificate.yaml", "vault-rbac.yaml"]
  template_path   = "${path.module}/../generate-files/templates/pm4ml"
  output_path     = "${var.output_dir}/${each.key}"
  app_file        = "pm4ml-app.yaml"
  app_file_prefix = each.key
  app_output_path = "${var.output_dir}/app-yamls"
}


variable "app_var_map" {
  type = any
}
variable "portal_fqdns" {
  description = "fqdns for pm4ml portal"
}
variable "experience_api_fqdns" {
  description = "fqdns for pm4ml experience api"
}
variable "mojaloop_connnector_fqdns" {
  description = "fqdns for pm4ml connector"
}
variable "test_fqdns" {
  description = "fqdns for pm4ml test"
}
variable "ttk_backend_fqdns" {
  description = "fqdns for pm4ml ttk back"
}
variable "ttk_frontend_fqdns" {
  description = "fqdns for pm4ml ttk front"
}

variable "pm4ml_vault_k8s_role_name" {
  description = "vault k8s role name for pm4ml"
  type        = string
  default     = "kubernetes-pm4ml-role"
}

resource "tls_private_key" "jws" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

variable "pm4ml_ingress_internal_lb" {
  type        = bool
  description = "pm4ml_ingress_internal_lb"
  default     = true
}

variable "pm4ml_chart_repo" {
  description = "repo for pm4ml charts"
  type        = string
  default     = "https://pm4ml.github.io/mojaloop-payment-manager-helm/repo"
}

variable "pm4ml_sync_wave" {
  type        = string
  description = "pm4ml_sync_wave"
  default     = "0"
}

variable "pm4ml_oidc_client_id_prefix" {
  type        = string
  description = "pm4ml_oidc_client_id_prefix"
  default     = "pm4ml-customer-ui"
}

variable "pm4ml_oidc_client_secret_secret_key" {
  type = string
}
variable "pm4ml_oidc_client_secret_secret_prefix" {
  type = string
}

variable "keycloak_pm4ml_realm_name" {
  type        = string
  description = "name of realm for pm4ml api access"
  default     = "pm4mls"
}

variable "keycloak_name" {
  type        = string
  description = "name of keycloak instance"
}

variable "keycloak_fqdn" {
  type        = string
  description = "fqdn of keycloak"
}
variable "keycloak_namespace" {
  type        = string
  description = "namespace of keycloak in which to create realm"
}
variable "pm4ml_service_account_name" {
  type        = string
  description = "service account name for pm4ml"
  default     = "pm4ml"
}

variable "pm4ml_external_switch_client_secret" {
  type        = string
  description = "secret name for client secret to connect to switch idm"
  default     = "pm4ml-external-switch-client-secret"
}

variable "use_ttk_as_backend_simulator" {
  type        = bool
  description = "use_ttk_as_backend_simulator"
  default     = false
}

variable "enable_sdk_bulk_transaction_support" {
  type        = bool
  description = "enable_sdk_bulk_transaction_support"
  default     = false
}

locals {
  nat_cidr_list = join(", ", [for ip in var.nat_public_ips : format("%s/32", ip)])
}