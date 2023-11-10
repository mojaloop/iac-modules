module "generate_pm4ml_files" {
  source = "../generate-files"
  var_map = {
    pm4ml_enabled                                   = var.pm4ml_enabled
    gitlab_project_url                              = var.gitlab_project_url
    pm4ml_chart_repo                                = var.pm4ml_chart_repo
    pm4ml_release_name                              = var.pm4ml_release_name
    pm4ml_namespace                                 = var.pm4ml_namespace
    storage_class_name                              = var.storage_class_name
    pm4ml_sync_wave                                 = var.pm4ml_sync_wave
    external_load_balancer_dns                      = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name            = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace                = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name            = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace                = var.istio_external_gateway_namespace
    pm4ml_wildcard_gateway                          = local.pm4ml_wildcard_gateway
    keycloak_fqdn                                   = var.keycloak_fqdn
    keycloak_pm4ml_realm_name                       = var.keycloak_pm4ml_realm_name
    experience_api_fqdn                             = var.experience_api_fqdn
    portal_fqdn                                     = var.portal_fqdn
    dfsp_id                                         = local.dfsp_id
    pm4ml_service_account_name                      = var.pm4ml_service_account_name
    mcm_host_url                                    = local.mcm_host_url
    server_cert_secret_namespace                    = var.pm4ml_namespace
    server_cert_secret_name                         = var.vault_certman_secretname
    vault_certman_secretname                        = var.vault_certman_secretname
    vault_pki_mount                                 = var.vault_root_ca_name
    vault_pki_client_role                           = var.pki_client_cert_role
    vault_pki_server_role                           = var.pki_server_cert_role
    vault_k8s_role                                  = var.pm4ml_vault_k8s_role_name
    vault_endpoint                                  = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pm4ml_vault_k8s_role_name                       = var.pm4ml_vault_k8s_role_name
    k8s_auth_path                                   = var.k8s_auth_path
    pm4ml_secret_path                               = local.pm4ml_secret_path
    callback_url                                    = "https://${var.mojaloop_connnector_fqdn}"
    mojaloop_connnector_fqdn                        = var.mojaloop_connnector_fqdn
    callback_fqdn                                   = var.mojaloop_connnector_fqdn
    redis_port                                      = "6379"
    redis_host                                      = "redis-master"
    redis_replica_count                             = "1"
    nat_ip_list                                     = local.nat_cidr_list
    pm4ml_oidc_client_id                            = var.pm4ml_oidc_client_id
    pm4ml_oidc_client_secret_secret_name            = join("$", ["", "{${replace(var.pm4ml_oidc_client_secret_secret, "-", "_")}}"])
    pm4ml_oidc_client_secret_secret                 = var.pm4ml_oidc_client_secret_secret
    pm4ml_oidc_client_secret_secret_key             = var.pm4ml_oidc_client_secret_secret_key
    keycloak_namespace                              = var.keycloak_namespace
    keycloak_name                                   = var.keycloak_name
    pm4ml_external_switch_fqdn                      = var.app_var_map.pm4ml_external_switch_fqdn
    pm4ml_chart_version                             = var.app_var_map.pm4ml_chart_version
    pm4ml_external_switch_client_id                 = var.app_var_map.pm4ml_external_switch_client_id
    pm4ml_external_switch_oidc_url                  = var.app_var_map.pm4ml_external_switch_oidc_url
    pm4ml_external_switch_oidc_token_route          = var.app_var_map.pm4ml_external_switch_oidc_token_route
    pm4ml_external_switch_client_secret             = var.pm4ml_external_switch_client_secret
    pm4ml_external_switch_client_secret_key         = "token"
    pm4ml_external_switch_client_secret_vault_key   = "${var.kv_path}/${var.cluster_name}/${var.app_var_map.pm4ml_external_switch_client_secret_vault_path}"
    pm4ml_external_switch_client_secret_vault_value = "value"
    istio_external_gateway_name                     = var.istio_external_gateway_name
    cert_man_vault_cluster_issuer_name              = var.cert_man_vault_cluster_issuer_name
    enable_sdk_bulk_transaction_support             = var.enable_sdk_bulk_transaction_support
    kafka_host                                      = "kafka"
    kafka_port                                      = "9092"
    ttk_enabled                                     = var.app_var_map.pm4ml_ttk_enabled
    use_ttk_as_backend_simulator                    = var.use_ttk_as_backend_simulator
    ttk_backend_fqdn                                = var.ttk_backend_fqdn
    ttk_frontend_fqdn                               = var.ttk_frontend_fqdn
    test_fqdn                                       = var.test_fqdn
  }
  file_list       = ["istio-gateway.yaml", "keycloak-realm-cr.yaml", "kustomization.yaml", "values-pm4ml.yaml", "vault-secret.yaml", "vault-certificate.yaml", "vault-rbac.yaml"]
  template_path   = "${path.module}/../generate-files/templates/pm4ml"
  output_path     = "${var.output_dir}/pm4ml"
  app_file        = "pm4ml-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  pm4ml_wildcard_gateway = var.app_var_map.pm4ml_ingress_internal_lb ? "internal" : "external"
  mcm_host_url           = "https://${var.app_var_map.pm4ml_external_mcm_public_fqdn}"
  dfsp_id                = try(var.app_var_map.pm4ml_dfsp_id, var.cluster_name)
  pki_root_name          = "pki-${var.pm4ml_release_name}"
}

variable "app_var_map" {
  type = any
}
variable "portal_fqdn" {
  description = "fqdn for pm4ml portal"
}
variable "experience_api_fqdn" {
  description = "fqdn for pm4ml experience api"
}
variable "mojaloop_connnector_fqdn" {
  description = "fqdn for pm4ml connector"
}
variable "test_fqdn" {
  description = "fqdn for pm4ml test"
}
variable "ttk_backend_fqdn" {
  description = "fqdn for pm4ml ttk back"
}
variable "ttk_frontend_fqdn" {
  description = "fqdn for pm4ml ttk front"
}

variable "pm4ml_vault_k8s_role_name" {
  description = "vault k8s role name for pm4ml"
  type        = string
  default     = "kubernetes-pm4ml-role"
}

variable "pm4ml_enabled" {
  description = "whether pm4ml app is enabled or not"
  type        = bool
  default     = true
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

variable "pm4ml_namespace" {
  description = "namespace for pm4ml release"
  type        = string
  default     = "pm4ml"
}

variable "pm4ml_release_name" {
  description = "name for pm4ml release"
  type        = string
  default     = "pm4ml"
}


variable "pm4ml_sync_wave" {
  type        = string
  description = "pm4ml_sync_wave"
  default     = "0"
}

variable "pm4ml_oidc_client_id" {
  type        = string
  description = "pm4ml_oidc_client_id"
  default     = "pm4ml-customer-ui"
}

variable "pm4ml_oidc_client_secret_secret_key" {
  type = string
}
variable "pm4ml_oidc_client_secret_secret" {
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
