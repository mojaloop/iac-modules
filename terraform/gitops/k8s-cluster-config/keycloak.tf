module "generate_keycloak_files" {
  source = "../generate-files"
  var_map = {
    keycloak_name                         = var.keycloak_name
    keycloak_operator_version             = var.common_var_map.keycloak_operator_version
    keycloak_namespace                    = var.keycloak_namespace
    gitlab_project_url                    = var.gitlab_project_url
    keycloak_postgres_database            = local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_config.database_name
    keycloak_postgres_user                = local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_config.username
    keycloak_postgres_host                = "${local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    keycloak_postgres_password_secret     = local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_config.user_password_secret
    keycloak_postgres_port                = local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_config.logical_service_port
    keycloak_postgres_password_secret_key = "password"
    keycloak_fqdn                         = local.keycloak_fqdn
    keycloak_admin_fqdn                   = local.keycloak_admin_fqdn
    keycloak_dfsp_realm_name              = var.keycloak_dfsp_realm_name
    keycloak_sync_wave                    = var.keycloak_sync_wave
    keycloak_post_config_sync_wave        = var.keycloak_post_config_sync_wave
    ingress_class                         = var.keycloak_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_internal_wildcard_gateway_name  = local.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace      = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name  = local.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace      = var.istio_external_gateway_namespace
    istio_external_gateway_name           = var.istio_external_gateway_name
    keycloak_wildcard_gateway             = local.keycloak_wildcard_gateway
    external_ingress_class_name           = var.external_ingress_class_name
    keycloak_tls_secretname               = var.default_ssl_certificate
    istio_create_ingress_gateways         = var.istio_create_ingress_gateways
    ref_secrets                           = local.keycloak_realm_env_secret_map
    ref_secrets_path                      = local.keycloak_secrets_path
    ory_stack_enabled                     = var.ory_stack_enabled
    external_load_balancer_dns            = var.external_load_balancer_dns
  }
  file_list = ["install/kustomization.yaml", "post-config/kustomization.yaml", "post-config/keycloak-cr.yaml",
  "post-config/vault-secret.yaml", "post-config/keycloak-ingress.yaml", "keycloak-install.yaml", "keycloak-post-config.yaml"]
  template_path   = "${path.module}/../generate-files/templates/keycloak"
  output_path     = "${var.output_dir}/keycloak"
  app_file        = "keycloak-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "keycloak_ingress_internal_lb" {
  type        = bool
  description = "keycloak_ingress_internal_lb"
  default     = false
}

variable "keycloak_name" {
  default = "switch-keycloak"
  type = string
  description = "name of keycloak instance"
}

variable "keycloak_sync_wave" {
  type        = string
  description = "keycloak_sync_wave"
  default     = "-4"
}

variable "keycloak_post_config_sync_wave" {
  type        = string
  description = "keycloak_post_config_sync_wave"
  default     = "-3"
}

variable "keycloak_namespace" {
  type        = string
  description = "keycloak_namespace"
  default     = "keycloak"
}
# rm this later, this is for nginx backwards compatability, not used in istio
variable "keycloak_dfsp_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "dfsps"
}

locals {
  keycloak_postgres_resource_index = index(local.stateful_resources.*.resource_name, "keycloak-db")
  keycloak_wildcard_gateway        = var.keycloak_ingress_internal_lb ? "internal" : "external"
  keycloak_fqdn                    = "keycloak.${var.public_subdomain}"
  keycloak_admin_fqdn              = "admin-keycloak.${var.public_subdomain}"
  keycloak_secrets_path            = "/secret/keycloak"
}
