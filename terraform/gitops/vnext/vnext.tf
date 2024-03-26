module "generate_vnext_files" {
  source = "../generate-files"
  var_map = {
    vnext_enabled                            = var.vnext_enabled
    gitlab_project_url                       = var.gitlab_project_url
    vnext_chart_repo                         = var.vnext_chart_repo
    vnext_chart_version                      = try(var.app_var_map.vnext_chart_version, var.vnext_chart_version)
    vnext_release_name                       = var.vnext_release_name
    vnext_namespace                          = var.vnext_namespace
    interop_switch_fqdn                      = var.external_interop_switch_fqdn
    int_interop_switch_fqdn                  = var.internal_interop_switch_fqdn
    storage_class_name                       = var.storage_class_name
    vnext_sync_wave                          = var.vnext_sync_wave
    vault_certman_secretname                 = var.vault_certman_secretname
    istio_create_ingress_gateways            = var.istio_create_ingress_gateways
    istio_external_gateway_name              = var.istio_external_gateway_name
    external_load_balancer_dns               = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name     = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace         = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name     = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace         = var.istio_external_gateway_namespace
    vnext_wildcard_gateway                   = local.vnext_wildcard_gateway
    keycloak_fqdn                            = var.keycloak_fqdn
    keycloak_realm_name                      = var.keycloak_hubop_realm_name
    ttk_frontend_public_fqdn                 = var.ttk_frontend_public_fqdn
    ttk_backend_public_fqdn                  = var.ttk_backend_public_fqdn
    kafka_host                               = "${local.stateful_resources[local.vnext_kafka_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kafka_port                               = local.stateful_resources[local.vnext_kafka_resource_index].logical_service_config.logical_service_port
    redis_host                               = "${local.stateful_resources[local.vnext_redis_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    redis_port                               = local.stateful_resources[local.vnext_redis_resource_index].logical_service_config.logical_service_port
    enable_istio_injection                   = try(var.app_var_map.enable_istio_injection, false)
    bof_release_name                         = var.bof_release_name
    ory_namespace                            = var.ory_namespace
    bof_role_perm_operator_host              = "${var.bof_release_name}-security-role-perm-operator-svc.${var.ory_namespace}.svc.cluster.local"
    auth_fqdn                                = var.auth_fqdn
    vnext_mongodb_database                   = local.stateful_resources[local.vnext_mongodb_resource_index].logical_service_config.database_name
    vnext_mongodb_user                       = local.stateful_resources[local.vnext_mongodb_resource_index].logical_service_config.username
    vnext_mongodb_host                       = "${local.stateful_resources[local.vnext_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    vnext_mongodb_existing_secret            = local.stateful_resources[local.vnext_mongodb_resource_index].logical_service_config.user_password_secret
    vnext_mongodb_port                       = local.stateful_resources[local.vnext_mongodb_resource_index].logical_service_config.logical_service_port
    vnext_mongodb_existing_secret_vault_path = local.stateful_resources[local.vnext_mongodb_resource_index].local_resource_config.generate_secret_vault_base_path # this should go away once vnext supports passing fine grained mongo config
    vnext_mongodb_resource_name              = "vnext-mongodb"
    vnext_mongo_url_secret_name              = "vnext-mongodb-url" ## this goes away as well
    keto_read_url                            = "http://keto-read.${var.ory_namespace}.svc.cluster.local:80"
    keto_write_url                           = "http://keto-write.${var.ory_namespace}.svc.cluster.local:80"
    kratos_service_name                      = "kratos-public.${var.ory_namespace}.svc.cluster.local"
    portal_fqdn                              = var.finance_portal_fqdn
    finance_portal_release_name              = "fin-portal"
    finance_portal_chart_version             = try(var.app_var_map.finance_portal_chart_version, var.finance_portal_chart_version)
    ory_stack_enabled                        = var.ory_stack_enabled
    oathkeeper_auth_provider_name            = var.oathkeeper_auth_provider_name
    vault_secret_key                         = var.vault_secret_key
    role_assign_svc_secret                   = var.role_assign_svc_secret
    role_assign_svc_user                     = var.role_assign_svc_user
    keycloak_dfsp_realm_name                 = var.keycloak_dfsp_realm_name
    apiResources                             = local.apiResources
    switch_dfspid                            = var.switch_dfspid
    jws_key_secret                           = local.jws_key_secret
    jws_key_secret_private_key_key           = "tls.key"
    jws_key_secret_public_key_key            = "tls.crt"
    cert_man_vault_cluster_issuer_name       = var.cert_man_vault_cluster_issuer_name
    jws_key_rsa_bits                         = try(var.app_var_map.jws_key_rsa_bits, var.jws_key_rsa_bits)
    jws_rotation_renew_before_hours          = try(var.app_var_map.jws_rotation_renew_before_hours, var.jws_rotation_renew_before_hours)
    jws_rotation_period_hours                = try(var.app_var_map.jws_rotation_period_hours, var.jws_rotation_period_hours)
    mcm_hub_jws_endpoint                     = "http://mcm-connection-manager-api.${var.mcm_namespace}.svc.cluster.local:3001/api/hub/jwscerts"
  }
  file_list       = [for f in fileset(local.vnext_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.vnext_app_file, f))]
  template_path   = local.vnext_template_path
  output_path     = "${var.output_dir}/vnext"
  app_file        = local.vnext_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}


locals {
  vnext_template_path          = "${path.module}/../generate-files/templates/vnext"
  vnext_app_file               = "vnext-app.yaml"
  vnext_kafka_resource_index   = index(local.stateful_resources.*.resource_name, "vnext-kafka")
  vnext_redis_resource_index   = index(local.stateful_resources.*.resource_name, "vnext-redis")
  vnext_mongodb_resource_index = index(local.stateful_resources.*.resource_name, "vnext-mongodb")
  vnext_wildcard_gateway       = var.vnext_ingress_internal_lb ? "internal" : "external"
  apiResources                 = yamldecode(file(var.rbac_api_resources_file))
  jws_key_secret               = "switch-jws"
}

variable "app_var_map" {
  type = any
}
variable "vnext_enabled" {
  description = "whether vnext app is enabled or not"
  type        = bool
  default     = true
}

variable "vnext_ingress_internal_lb" {
  type        = bool
  description = "vnext_ingress_internal_lb"
  default     = true
}

variable "vnext_chart_repo" {
  description = "repo for vnext charts"
  type        = string
  default     = "https://mojaloop.github.io/vn-helm/"
}

variable "vnext_namespace" {
  description = "namespace for vnext release"
  type        = string
  default     = "vnext"
}

variable "vnext_release_name" {
  description = "name for vnext release"
  type        = string
  default     = "vnext"
}

variable "vnext_chart_version" {
  description = "vnext version to install via Helm"
}

variable "finance_portal_chart_version" {
  description = "finance portal chart version"
  default     = "4.2.3"
}

variable "vnext_sync_wave" {
  type        = string
  description = "vnext_sync_wave"
  default     = "0"
}

variable "ttk_frontend_public_fqdn" {
  type = string
}
variable "ttk_backend_public_fqdn" {
  type = string
}

variable "auth_fqdn" {
  type = string
}
variable "ory_namespace" {
  type = string
}

variable "finance_portal_fqdn" {
  type = string
}

variable "bof_release_name" {
  type = string
}
variable "ory_stack_enabled" {
  type = bool
}
variable "oathkeeper_auth_provider_name" {
  type = string
}
variable "keycloak_hubop_realm_name" {
  type        = string
  description = "name of realm for hub operator api access"
}

variable "vault_secret_key" {
  type = string
}

variable "role_assign_svc_secret" {
  type = string
}
variable "role_assign_svc_user" {
  type = string
}

variable "rbac_api_resources_file" {
  type = string
}

variable "jws_key_rsa_bits" {
  type    = number
  default = 4096
}

variable "jws_rotation_period_hours" {
  type    = number
  default = 672
}

variable "jws_rotation_renew_before_hours" {
  type    = number
  default = 1
}

variable "ttk_gp_testcase_labels" {
  type    = string
  default = "p2p"
}
