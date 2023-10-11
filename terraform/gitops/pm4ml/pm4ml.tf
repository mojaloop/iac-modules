module "generate_pm4ml_files" {
  source = "../generate-files"
  var_map = {
    pm4ml_enabled                        = var.pm4ml_enabled
    gitlab_project_url                   = var.gitlab_project_url
    pm4ml_chart_repo                     = var.pm4ml_chart_repo
    pm4ml_chart_version                  = var.pm4ml_chart_version
    pm4ml_release_name                   = var.pm4ml_release_name
    pm4ml_namespace                      = var.pm4ml_namespace
    storage_class_name                   = var.storage_class_name
    pm4ml_sync_wave                      = var.pm4ml_sync_wave
    external_load_balancer_dns           = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    pm4ml_wildcard_gateway               = local.pm4ml_wildcard_gateway
    keycloak_fqdn                        = var.keycloak_fqdn
    keycloak_dfsp_realm_name             = var.keycloak_dfsp_realm_name
    experience_api_fqdn                  = local.experience_api_fqdn
    portal_fqdn                          = local.portal_fqdn
    experience_api_client_secret         = experience_api_client_secret
    dfsp_id                              = local.dfsp_id
    pm4ml_service_account_name           = var.pm4ml_service_account_name
    mcm_host_url                         = local.mcm_host_url
    server_cert_secret_namespace         = var.pm4ml_namespace
    server_cert_secret_name              = var.vault_certman_secretname
    vault_certman_secretname             = var.vault_certman_secretname
    vault_kv_mount                       = var.local_vault_kv_root_path
    local_vault_kv_root_path             = var.local_vault_kv_root_path
    vault_pki_mount                      = var.vault_root_ca_name
    vault_pki_client_role                = var.pki_client_cert_role
    vault_pki_server_role                = var.pki_server_cert_role
    vault_k8s_role                       = var.pm4ml_vault_k8s_role_name
    vault_endpoint                       = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pm4ml_vault_k8s_role_name            = var.pm4ml_vault_k8s_role_name
    k8s_auth_path                        = var.k8s_auth_path
    pm4ml_secret_path                    = var.pm4ml_secret_path
    callback_url                         = local.mojaloop_connnector_fqdn
    mojaloop_connnector_fqdn             = local.mojaloop_connnector_fqdn
    redis_port                           = "6379"
    redis_host                           = "redis-master"
    nat_ip_list                          = var.nat_public_ips
  }
  file_list       = ["istio-gateway.yaml", "keycloak-realm-cr.yaml", "kustomization.yaml", "values-pm4ml.yaml", "vault-secret.yaml", "vault-certificate.yaml", "vault-rbac.yaml"]
  template_path   = "${path.module}/../generate-files/templates/pm4ml"
  output_path     = "${var.output_dir}/pm4ml"
  app_file        = "pm4ml-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

data "vault_generic_secret" "pm4ml_external_switch_client_secret" {
  path = "${var.kv_path}/${var.cluster_name}/${var.pm4ml_external_switch_client_secret_vault_path}"
}

locals {
  portal_fqdn              = "portal.${public_subdomain}"
  experience_api_fqdn      = "experience-api.${public_subdomain}"
  pm4ml_wildcard_gateway   = var.pm4ml_ingress_internal_lb ? "internal" : "external"
  mcm_host_url             = "https://${var.pm4ml_external_mcm_public_fqdn}"
  mojaloop_connnector_fqdn = "connector.${public_subdomain}"
  dfsp_id                  = var.cluster_name
}

variable "pm4ml_secret_path" {
  description = "vault kv secret path for pm4ml use"
  type        = string
  default     = "secret/pm4ml"
}

variable "pm4ml_vault_k8s_role_name" {
  description = "vault k8s role name for pm4ml"
  type        = string
  default     = "kubernetes-mcm-role"
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

variable "pm4ml_chart_version" {
  description = "pm4ml version to install via Helm"
}

variable "pm4ml_sync_wave" {
  type        = string
  description = "pm4ml_sync_wave"
  default     = "0"
}

variable "pm4ml_oidc_client_secret_secret_key" {
  type = string
}
variable "pm4ml_oidc_client_secret_secret" {
  type = string
}
variable "jwt_client_secret_secret_key" {
  type = string
}
variable "jwt_client_secret_secret" {
  type = string
}

variable "keycloak_dfsp_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "dfsps"
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

variable "pm4ml_external_mcm_public_fqdn" {
  type        = string
  description = "fqdn of mcm of switch"
}

variable "pm4ml_external_switch_oidc_url" {
  type        = string
  description = "url to connect to authenticate on switch"
}

variable "pm4ml_external_switch_client_id" {
  type        = string
  description = "clientid to connect to switch idm"
}

variable "pm4ml_external_switch_client_secret_vault_path" {
  type        = string
  description = "path in tenant vault to get client secret to connect to switch idm"
}