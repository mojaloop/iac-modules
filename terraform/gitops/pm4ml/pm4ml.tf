module "generate_pm4ml_files" {
  for_each = var.app_var_map
  source   = "../generate-files"
  var_map = {
    pm4ml_enabled                                   = each.value.pm4ml_enabled
    gitlab_project_url                              = var.gitlab_project_url
    pm4ml_chart_repo                                = var.pm4ml_chart_repo
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
    keycloak_fqdn                                   = var.keycloak_fqdn
    keycloak_pm4ml_realm_name                       = "${var.keycloak_pm4ml_realm_name}-${each.key}"
    experience_api_fqdn                             = var.experience_api_fqdns[each.key]
    kratos_service_name                             = "kratos-public.${var.ory_namespace}.svc.cluster.local"
    portal_fqdn                                     = var.portal_fqdns[each.key]
    admin_portal_fqdn                               = var.admin_portal_fqdns[each.key]
    auth_fqdn                                       = var.auth_fqdn
    admin_portal_release_name                       = "admin-portal-${each.key}"
    admin_portal_chart_version                      = try(var.app_var_map.admin_portal_chart_version, var.admin_portal_chart_version)
    dfsp_id                                         = each.value.pm4ml_dfsp_id
    pm4ml_service_account_name                      = "${var.pm4ml_service_account_name}-${each.key}"
    mcm_host_url                                    = "https://${each.value.pm4ml_external_mcm_public_fqdn}"
    server_cert_secret_namespace                    = each.key
    server_cert_secret_name                         = var.vault_certman_secretname
    vault_certman_secretname                        = var.vault_certman_secretname
    vault_pki_mount                                 = var.vault_root_ca_name
    vault_pki_client_role                           = var.pki_client_cert_role
    vault_pki_server_role                           = var.pki_server_cert_role
    vault_endpoint                                  = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pm4ml_vault_k8s_role_name                       = "${var.pm4ml_vault_k8s_role_name}-${each.key}"
    k8s_auth_path                                   = var.k8s_auth_path
    keto_read_url                                   = "http://keto-read.${var.ory_namespace}.svc.cluster.local:80"
    keto_write_url                                  = "http://keto-write.${var.ory_namespace}.svc.cluster.local:80"
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
    vault_secret_key                                = var.vault_secret_key
    keycloak_namespace                              = var.keycloak_namespace
    keycloak_name                                   = var.keycloak_name
    pm4ml_external_switch_fqdn                      = each.value.pm4ml_external_switch_fqdn
    pm4ml_chart_version                             = each.value.pm4ml_chart_version
    pm4ml_external_switch_client_id                 = each.value.pm4ml_external_switch_client_id
    pm4ml_external_switch_oidc_url                  = each.value.pm4ml_external_switch_oidc_url
    pm4ml_external_switch_oidc_token_route          = each.value.pm4ml_external_switch_oidc_token_route
    pm4ml_external_switch_client_secret             = var.pm4ml_external_switch_client_secret
    pm4ml_external_switch_client_secret_key         = "token"
    pm4ml_external_switch_client_secret_vault_key   = "${var.kv_path}/${var.cluster_name}/${each.key}/${each.value.pm4ml_external_switch_client_secret_vault_path}"
    pm4ml_external_switch_client_secret_vault_value = "value"
    istio_external_gateway_name                     = var.istio_external_gateway_name
    cert_man_vault_cluster_issuer_name              = var.cert_man_vault_cluster_issuer_name
    enable_sdk_bulk_transaction_support             = each.value.enable_sdk_bulk_transaction_support
    kafka_host                                      = "kafka"
    kafka_port                                      = "9092"
    ttk_enabled                                     = each.value.pm4ml_ttk_enabled
    use_ttk_as_backend_simulator                    = each.value.use_ttk_as_backend_simulator
    ttk_backend_fqdn                                = var.ttk_backend_fqdns[each.key]
    ttk_frontend_fqdn                               = var.ttk_frontend_fqdns[each.key]
    test_fqdn                                       = var.test_fqdns[each.key]
    ory_namespace                                   = var.ory_namespace
    ory_stack_enabled                               = var.ory_stack_enabled
    oathkeeper_auth_provider_name                   = var.oathkeeper_auth_provider_name
    istio_create_ingress_gateways                   = var.istio_create_ingress_gateways
    bof_release_name                                = var.bof_release_name
    bof_role_perm_operator_host                     = "${var.bof_release_name}-security-role-perm-operator-svc.${var.ory_namespace}.svc.cluster.local"
    portal_admin_secret                             = "${var.portal_admin_secret_prefix}${each.key}"
    portal_admin_secret_name                        = join("$", ["", "{${replace("${var.portal_admin_secret_prefix}${each.key}", "-", "_")}}"])
    portal_admin_user                               = var.portal_admin_user
    role_assign_svc_secret                          = "${var.role_assign_svc_secret_prefix}${each.key}"
    role_assign_svc_secret_name                     = join("$", ["", "{${replace("${var.role_assign_svc_secret_prefix}${each.key}", "-", "_")}}"])
    role_assign_svc_user                            = var.role_assign_svc_user
    pm4ml_reserve_notification                      = each.value.pm4ml_reserve_notification
    pm4ml_core_connector_image_repository           = var.pm4ml_core_connector_image_repository
    pm4ml_core_connector_image_tag                  = var.pm4ml_core_connector_image_tag
    pm4ml_core_connector_env                        = var.pm4ml_core_connector_env
  }

  file_list       = [for f in fileset(local.pm4ml_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.pm4ml_app_file, f))]
  template_path   = local.pm4ml_template_path
  output_path     = "${var.output_dir}/${each.key}"
  app_file        = local.pm4ml_app_file
  app_file_prefix = each.key
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  pm4ml_template_path = "${path.module}/../generate-files/templates/pm4ml"
  pm4ml_app_file      = "pm4ml-app.yaml"
}


variable "app_var_map" {
  type = any
}
variable "portal_fqdns" {
  description = "fqdns for pm4ml portal"
}
variable "admin_portal_fqdns" {
  description = "fqdns for pm4ml admin portal"
}
variable "auth_fqdn" {
  type = string
}
variable "ory_stack_enabled" {
  type = bool
}
variable "oathkeeper_auth_provider_name" {
  type = string
}
variable "experience_api_fqdns" {
  description = "fqdns for pm4ml experience api"
}
variable "pm4ml_core_connector_image_repository" {
  description = "Image repository for pm4ml core connector"
  type        = string
  default     = "pm4ml/mojaloop-payment-manager-simulator-core-connector"
}

variable "pm4ml_core_connector_env" {
  description = "Environment variables"
  type        = map(string)
  default     = {
    BACKEND_ENDPOINT           = "http://localhost:3002"
    MLCONN_OUTBOUND_ENDPOINT   = "http://localhost:4001"
    // Add more variables here
  }
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
  type        = number
  description = "pm4ml_sync_wave"
  default     = 0
}

variable "admin_portal_chart_version" {
  description = "admin (finance) portal chart version"
  default     = "4.2.3"
}

variable "pm4ml_oidc_client_id_prefix" {
  type        = string
  description = "pm4ml_oidc_client_id_prefix"
}

variable "vault_secret_key" {
  type = string
}
variable "pm4ml_oidc_client_secret_secret_prefix" {
  type = string
}

variable "keycloak_pm4ml_realm_name" {
  type        = string
  description = "name of realm for pm4ml api access"
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
variable "ory_namespace" {
  type = string
}
variable "bof_release_name" {
  type = string
}

variable "portal_admin_user" {
  type = string
}

variable "role_assign_svc_user" {
  type = string
}

variable "role_assign_svc_secret_prefix" {
  type = string
}

variable "portal_admin_secret_prefix" {
  type = string
}
locals {
  nat_cidr_list = join(", ", [for ip in var.nat_public_ips : format("%s/32", ip)])
}
