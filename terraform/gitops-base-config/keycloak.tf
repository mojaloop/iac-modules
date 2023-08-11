module "generate_keycloak_files" {
  source = "./generate-files"
  var_map = {
    keycloak_name                         = "switch-keycloak"
    keycloak_operator_version             = var.keycloak_operator_version
    keycloak_namespace                    = var.keycloak_namespace
    gitlab_project_url                    = var.gitlab_project_url
    keycloak_postgres_database            = local.stateful_resources[local.keycloak_postgres_resource_index].local_resource.pgsql_data.database_name
    keycloak_postgres_user                = local.stateful_resources[local.keycloak_postgres_resource_index].local_resource.pgsql_data.user
    keycloak_postgres_host                = "${local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    keycloak_postgres_password_secret     = local.stateful_resources[local.keycloak_postgres_resource_index].generate_secret_name
    keycloak_postgres_port                = local.stateful_resources[local.keycloak_postgres_resource_index].logical_service_port
    keycloak_postgres_password_secret_key = "password"
    keycloak_fqdn                         = "keycloak.${var.public_subdomain}"
    keycloak_dfsp_realm_name              = var.keycloak_dfsp_realm_name
    keycloak_sync_wave                    = var.keycloak_sync_wave
    ingress_class                         = var.keycloak_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    external_ingress_class_name           = var.external_ingress_class_name
    keycloak_tls_secretname               = var.default_ssl_certificate
    mcm_namespace                         = var.mcm_namespace
    mcm_oidc_client_secret_secret         = var.mcm_oauth_secret_secret
    mcm_oidc_client_secret_secret_key     = var.mcm_oauth_secret_secret_key
    mcm_oidc_client_id                    = var.mcm_oidc_client_id
  }
  file_list       = ["kustomization.yaml", "keycloak-cr.yaml", "keycloak-realm-cr.yaml", "keycloak-ingress.yaml", "vault-secret.yaml"]
  template_path   = "${path.module}/generate-files/templates/keycloak"
  output_path     = "${var.output_dir}/keycloak"
  app_file        = "keycloak-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "keycloak_ingress_internal_lb" {
  type        = bool
  description = "keycloak_ingress_internal_lb"
  default     = true
}


variable "keycloak_operator_version" {
  type        = string
  default     = "22.0.1"
  description = "keycloak_operator_version"
}

variable "keycloak_sync_wave" {
  type        = string
  description = "keycloak_sync_wave"
  default     = "-1"
}

variable "keycloak_namespace" {
  type        = string
  description = "keycloak_namespace"
  default     = "keycloak"
}

variable "keycloak_dfsp_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "dfsps"
}

locals {
  keycloak_postgres_resource_index = index(local.stateful_resources.*.resource_name, "keycloak-db")
}
