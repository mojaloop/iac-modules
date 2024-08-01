module "generate_mcm_files" {
  source = "../generate-files"
  var_map = {
    mcm_enabled                          = var.mcm_enabled
    db_password_secret                   = module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.user_password_secret
    db_password_secret_key               = module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.user_password_secret_key
    db_user                              = module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.db_username
    db_schema                            = module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.database_name
    db_port                              = module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.logical_service_port
    db_host                              = "${module.mojaloop_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    mcm_fqdn                             = local.mcm_fqdn
    mcm_istio_gateway_namespace          = local.mcm_istio_gateway_namespace
    mcm_istio_wildcard_gateway_name      = local.mcm_istio_wildcard_gateway_name
    mcm_istio_gateway_name               = local.mcm_istio_gateway_name
    fspiop_use_ory_for_auth              = var.fspiop_use_ory_for_auth
    env_name                             = var.cluster_name
    env_cn                               = var.public_subdomain
    env_o                                = "Mojaloop"
    env_ou                               = "Infra"
    storage_class_name                   = var.storage_class_name
    server_cert_secret_name              = var.vault_certman_secretname
    vault_certman_secretname             = var.vault_certman_secretname
    server_cert_secret_namespace         = var.mcm_namespace
    oauth_key                            = var.mcm_oidc_client_id
    oauth_secret_secret                  = var.mcm_oidc_client_secret_secret
    oauth_secret_secret_key              = var.mcm_oidc_client_secret_secret_key
    switch_domain                        = var.public_subdomain
    vault_endpoint                       = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pki_base_domain                      = var.public_subdomain
    mcm_chart_repo                       = var.mcm_chart_repo
    mcm_chart_version                    = var.mcm_chart_version
    mcm_namespace                        = var.mcm_namespace
    gitlab_project_url                   = var.gitlab_project_url
    public_subdomain                     = var.public_subdomain
    enable_oidc                          = var.enable_mcm_oidc
    mcm_sync_wave                        = var.mcm_sync_wave
    ingress_class                        = try(var.app_var_map.mcm_ingress_internal_lb, false) ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways        = var.istio_create_ingress_gateways
    pki_path                             = var.vault_root_ca_name
    dfsp_client_cert_bundle              = local.dfsp_client_cert_bundle
    dfsp_internal_whitelist_secret       = local.dfsp_internal_whitelist_secret
    dfsp_external_whitelist_secret       = local.dfsp_external_whitelist_secret
    onboarding_secret_path               = local.dfsp_client_cert_bundle
    whitelist_secret_path                = local.whitelist_secret_path
    mcm_service_account_name             = var.mcm_service_account_name
    pki_client_role                      = var.pki_client_cert_role
    pki_server_role                      = var.pki_server_cert_role
    mcm_vault_k8s_role_name              = var.mcm_vault_k8s_role_name
    k8s_auth_path                        = var.k8s_auth_path
    mcm_secret_path                      = local.mcm_secret_path
    totp_issuer                          = "not-used-yet"
    token_issuer_fqdn                    = "keycloak.${var.public_subdomain}"
    nginx_external_namespace             = var.nginx_external_namespace
    istio_internal_wildcard_gateway_name = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    istio_egress_gateway_name            = var.istio_egress_gateway_name
    istio_egress_gateway_namespace       = var.istio_egress_gateway_namespace
    mcm_wildcard_gateway                 = local.mcm_wildcard_gateway
    istio_external_gateway_name          = var.istio_external_gateway_name
    private_network_cidr                 = var.private_network_cidr
    interop_switch_fqdn                  = local.external_interop_switch_fqdn
    keycloak_fqdn                        = var.keycloak_fqdn
    keycloak_dfsp_realm_name             = var.keycloak_dfsp_realm_name
    keycloak_hubop_realm_name            = var.keycloak_hubop_realm_name
    keycloak_name                        = var.keycloak_name
    keycloak_namespace                   = var.keycloak_namespace
    cert_man_vault_cluster_issuer_name   = var.cert_man_vault_cluster_issuer_name
    jwt_client_secret_secret_name        = join("$", ["", "{${replace(var.jwt_client_secret_secret, "-", "_")}}"])
    mcm_oidc_client_id                   = var.mcm_oidc_client_id
    mcm_oidc_client_secret_secret_name   = join("$", ["", "{${replace(var.mcm_oidc_client_secret_secret, "-", "_")}}"])
    jwt_client_secret_secret_key         = var.jwt_client_secret_secret_key
    jwt_client_secret_secret             = var.jwt_client_secret_secret
    mcm_oidc_client_secret_secret        = var.mcm_oidc_client_secret_secret
    mcm_oidc_client_secret_secret_key    = var.mcm_oidc_client_secret_secret_key
    internal_load_balancer_dns           = var.internal_load_balancer_dns
    external_load_balancer_dns           = var.external_load_balancer_dns
    istio_internal_gateway_name          = var.istio_internal_gateway_name
    int_interop_switch_fqdn              = local.internal_interop_switch_fqdn
    mojaloop_namespace                   = var.mojaloop_namespace
    mojaloop_release_name                = var.mojaloop_release_name
    onboarding_collection_tag            = var.app_var_map.onboarding_collection_tag
    oathkeeper_auth_provider_name        = var.oathkeeper_auth_provider_name
    auth_fqdn                            = var.auth_fqdn
    kratos_service_name                  = "kratos-public.${var.ory_namespace}.svc.cluster.local"
    keto_read_url                        = "http://keto-read.${var.ory_namespace}.svc.cluster.local:80"
    switch_dfspid                        = var.switch_dfspid
    pm4mls                               = {for name, value in var.pm4mls : name => value if !value.pm4ml_enabled || can(value.pm4ml_scheme_a_config)}
    dfsp_seed                            = join(",", [for name, value in var.pm4mls : "${name}:${value.currency}${can(value.pm4ml_scheme_a_config)?":proxy":""}" if length(try(value.currency, "")) > 0])
  }
  file_list       = [for f in fileset(local.mcm_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.mcm_app_file, f))]
  template_path   = local.mcm_template_path
  output_path     = "${var.output_dir}/mcm"
  app_file        = local.mcm_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "mcm_enabled" {
  description = "whether mcm app is enabled or not"
  type        = bool
  default     = true
}

variable "enable_mcm_oidc" {
  type    = bool
  default = false
}

variable "mcm_oauth_secret_secret" {
  type        = string
  description = "mcm_oauth_secret_secret"
  default     = "mcm-oidc-secret"
}

variable "mcm_oauth_secret_secret_key" {
  type        = string
  description = "mcm_oauth_secret_secret_key"
  default     = "secret"
}

variable "mcm_oidc_client_id" {
  type        = string
  description = "mcm_oidc_client_id"
  default     = "mcm-portal"
}

variable "mcm_chart_repo" {
  type        = string
  default     = "https://pm4ml.github.io/helm"
  description = "mcm_chart_repo"
}

variable "mcm_chart_version" {
  type        = string
  default     = "0.7.6"
  description = "mcm_chart_version"
}

variable "mcm_sync_wave" {
  type        = string
  description = "mcm_sync_wave"
  default     = "-2"
}

variable "mcm_namespace" {
  type        = string
  description = "mcm_namespace"
  default     = "mcm"
}

variable "mcm_service_account_name" {
  type        = string
  description = "service account name for mcm"
  default     = "mcm"
}

variable "mcm_vault_k8s_role_name" {
  description = "vault k8s role name for mcm"
  type        = string
  default     = "kubernetes-mcm-role"
}

variable "private_network_cidr" {
  description = "network cidr for private network"
  type        = string
}

variable "vault_certman_secretname" {
  description = "secret name to create for tls offloading via certmanager"
  type        = string
  default     = "vault-tls-cert"
}
variable "nginx_external_namespace" {
  type        = string
  description = "nginx_external_namespace"
}
variable "mcm_oidc_client_secret_secret_key" {
  type = string
}
variable "mcm_oidc_client_secret_secret" {
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

variable "fspiop_use_ory_for_auth" {
  type = bool
}

variable "pm4mls" {
  type = any
}

locals {
  mcm_template_path              = "${path.module}/../generate-files/templates/mcm"
  mcm_app_file                   = "mcm-app.yaml"
  mcm_resource_index             =  "mcm-db"
  mcm_wildcard_gateway           = try(var.app_var_map.mcm_ingress_internal_lb, false) ? "internal" : "external"
  dfsp_client_cert_bundle        = "${local.onboarding_secret_path}_pm4mls"
  dfsp_internal_whitelist_secret = "${local.whitelist_secret_path}_pm4mls"
  dfsp_external_whitelist_secret = "${local.whitelist_secret_path}_fsps"

  mcm_fqdn                        = local.mcm_wildcard_gateway == "external" ? "mcm.${var.public_subdomain}" : "mcm.${var.private_subdomain}"
  mcm_istio_gateway_namespace     = local.mcm_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  mcm_istio_wildcard_gateway_name = local.mcm_wildcard_gateway == "external" ? var.istio_external_wildcard_gateway_name : var.istio_internal_wildcard_gateway_name
  mcm_istio_gateway_name          = local.mcm_wildcard_gateway == "external" ? var.istio_external_gateway_name : var.istio_internal_gateway_name
}
