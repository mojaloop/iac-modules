resource "random_password" "mcm_dfsp_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "mcm_dfsp_api_service_secret" {
  length  = 32
  special = false
}

resource "random_password" "mcm_dfsp_auth_client_secret" {
  length  = 32
  special = false
}

module "generate_mcm_files" {
  source = "../generate-files"
  var_map = {
    mcm_enabled                          = var.mcm_enabled
    db_password_secret                   = module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.user_password_secret
    db_password_secret_key               = module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.user_password_secret_key
    db_user                              = module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.db_username
    db_schema                            = module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.database_name
    db_port                              = module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.logical_service_port
    db_host                              = "${module.vnext_stateful_resources.stateful_resources[local.mcm_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
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
    mojaloop_namespace                   = var.vnext_namespace
    mojaloop_release_name                = var.vnext_release_name
    onboarding_collection_tag            = var.app_var_map.onboarding_collection_tag
    oathkeeper_auth_provider_name        = var.oathkeeper_auth_provider_name
    auth_fqdn                            = var.auth_fqdn
    kratos_service_name                  = "kratos-public.${var.ory_namespace}.svc.cluster.local"
    keto_read_url                        = "http://keto-read.${var.ory_namespace}.svc.cluster.local:80"
    switch_dfspid                        = var.switch_dfspid
    mcm_custom_realm_name                = var.mcm_custom_realm_name
    mcm_custom_realm_config = templatefile("${local.mcm_template_path}/mcm-realm-config.yaml.tpl", {
      dfsp_api_service_secret = random_password.mcm_dfsp_api_service_secret.result
      dfsp_auth_client_secret = random_password.mcm_dfsp_auth_client_secret.result
      mcm_fqdn                = local.mcm_fqdn
      dfsps_admin_username    = var.dfsp_admin.username
      dfsps_admin_email       = var.dfsp_admin.email
      dfsps_admin_password    = random_password.mcm_dfsp_admin_password.result
      smtp_host               = var.smtp.host
      smtp_port               = var.smtp.port
      smtp_ssl                = var.smtp.ssl
      smtp_starttls           = var.smtp.starttls
      smtp_auth               = var.smtp.auth
      smtp_from               = var.smtp.from
      smtp_from_display_name  = var.smtp.from_display_name
      smtp_reply_to           = var.smtp.reply_to
    })
    dfsp_api_service_secret_name       = var.dfsp_secrets.api_service.secret_name
    dfsp_api_service_secret_key        = var.dfsp_secrets.api_service.secret_key
    dfsp_auth_client_secret_name       = var.dfsp_secrets.auth_client.secret_name
    dfsp_auth_client_secret_key        = var.dfsp_secrets.auth_client.secret_key
    openid_allow_insecure              = var.openid_allow_insecure
    openid_enabled                     = var.openid_enabled
    auth_2fa_enabled                   = var.auth_2fa_enabled
    keycloak_access_token_lifespan     = var.keycloak_access_token_lifespan
    mcm_ingress_whitelist_source_range = var.mcm_ingress_whitelist_source_range
    keycloak_config = {
      enabled              = true
      base_url             = "https://${var.keycloak_fqdn}"
      discovery_url        = "https://${var.keycloak_fqdn}/realms/${var.keycloak_dfsp_realm_name}/.well-known/openid-configuration"
      admin_client_id      = "connection-manager-api-service"
      dfsps_realm          = var.keycloak_dfsp_realm_name
      auto_create_accounts = true
    }
    auth_config = {
      two_fa_enabled = var.auth_2fa_enabled
    }
    openid_config = {
      enabled         = var.openid_enabled
      allow_insecure  = var.openid_allow_insecure
      discovery_url   = "https://${var.keycloak_fqdn}/realms/${var.keycloak_dfsp_realm_name}/.well-known/openid-configuration"
      client_id       = "connection-manager-auth-client"
      redirect_uri    = "https://${local.mcm_fqdn}/api/auth/callback"
      jwt_cookie_name = "MCM-API_ACCESS_TOKEN"
      everyone_role   = "everyone"
      mta_role        = "dfsp-admin"
    }
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
  default     = "0.8.0"
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
  type        = string
  description = "Key in the secret containing the MCM OIDC client secret"
  default     = "secret"
}
variable "mcm_oidc_client_secret_secret" {
  type        = string
  description = "Name of the secret containing the MCM OIDC client secret"
  default     = "mcm-oidc-client-secret"
}
variable "jwt_client_secret_secret_key" {
  type        = string
  description = "Key in the secret containing the JWT client secret"
  default     = "secret"
}
variable "jwt_client_secret_secret" {
  type        = string
  description = "Name of the secret containing the JWT client secret"
  default     = "jwt-client-secret"
}

variable "keycloak_dfsp_realm_name" {
  type        = string
  description = "Name of realm for DFSP API access in Keycloak"
  default     = "dfsps"

  validation {
    condition     = length(var.keycloak_dfsp_realm_name) > 0
    error_message = "The keycloak_dfsp_realm_name cannot be empty."
  }
}

variable "keycloak_name" {
  type        = string
  description = "Name of the Keycloak instance/deployment"

  validation {
    condition     = length(var.keycloak_name) > 0
    error_message = "The keycloak_name cannot be empty."
  }
}

variable "keycloak_fqdn" {
  type        = string
  description = "Fully qualified domain name of the Keycloak service"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.keycloak_fqdn))
    error_message = "The keycloak_fqdn must be a valid domain name."
  }
}

variable "keycloak_namespace" {
  type        = string
  description = "Kubernetes namespace where Keycloak is deployed"

  validation {
    condition     = length(var.keycloak_namespace) > 0
    error_message = "The keycloak_namespace cannot be empty."
  }
}

variable "fspiop_use_ory_for_auth" {
  type = bool
}

variable "mcm_custom_realm_name" {
  type        = string
  description = "Name of the custom MCM realm"
}

variable "mcm_custom_realm_config" {
  type        = string
  description = "Custom realm configuration in YAML format"
}

variable "smtp" {
  type = object({
    host              = string
    port              = number
    ssl               = bool
    starttls          = bool
    auth              = bool
    from              = string
    from_display_name = string
    reply_to          = string
  })
  description = "SMTP server configuration for email notifications"
  default = {
    host              = "mailhog"
    port              = 1025
    ssl               = false
    starttls          = false
    auth              = false
    from              = "noreply@mojaloop.io"
    from_display_name = "Mojaloop Hub"
    reply_to          = "noreply@mojaloop.io"
  }

  validation {
    condition     = var.smtp.port > 0 && var.smtp.port <= 65535
    error_message = "The smtp.port must be a valid port number between 1 and 65535."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.smtp.from))
    error_message = "The smtp.from must be a valid email address."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.smtp.reply_to))
    error_message = "The smtp.reply_to must be a valid email address."
  }

  validation {
    condition     = length(var.smtp.host) > 0
    error_message = "The smtp.host cannot be empty."
  }

  validation {
    condition     = length(var.smtp.from_display_name) > 0
    error_message = "The smtp.from_display_name cannot be empty."
  }
}

variable "dfsp_admin" {
  type = object({
    username = string
    email    = string
  })
  description = "DFSP admin user configuration"
  default = {
    username = "dfsp-admin"
    email    = ""
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.dfsp_admin.email))
    error_message = "The dfsp_admin.email must be a valid email address."
  }
}

variable "dfsp_secrets" {
  type = object({
    api_service = object({
      secret_name = string
      secret_key  = string
    })
    auth_client = object({
      secret_name = string
      secret_key  = string
    })
  })
  description = "DFSP client secret configuration for Keycloak authentication"
  default = {
    api_service = {
      secret_name = "mcm-api-service-secret"
      secret_key  = "secret"
    }
    auth_client = {
      secret_name = "mcm-auth-client-secret"
      secret_key  = "secret"
    }
  }
}

variable "openid_allow_insecure" {
  type        = bool
  description = "Allow insecure OpenID connections (for development)"
  default     = false
}

variable "openid_enabled" {
  type        = bool
  description = "OpenID enabled"
  default     = true
}

variable "auth_2fa_enabled" {
  type        = bool
  description = "2FA enabled"
  default     = true
}

variable "keycloak_access_token_lifespan" {
  type        = number
  description = "Access token lifespan in seconds for Keycloak clients"
  default     = 3600

  validation {
    condition     = var.keycloak_access_token_lifespan > 0
    error_message = "The keycloak_access_token_lifespan must be a positive number."
  }
}

variable "mcm_ingress_whitelist_source_range" {
  type        = string
  description = "Source IP ranges allowed to access MCM ingress (CIDR notation)"
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.mcm_ingress_whitelist_source_range))
    error_message = "The mcm_ingress_whitelist_source_range must be a valid CIDR notation (e.g., '10.0.0.0/16' or '0.0.0.0/0')."
  }
}

locals {
  mcm_template_path              = "${path.module}/../generate-files/templates/mcm"
  mcm_app_file                   = "mcm-app.yaml"
  mcm_resource_index             = "mcm-db"
  mcm_wildcard_gateway           = try(var.app_var_map.mcm_ingress_internal_lb, false) ? "internal" : "external"
  dfsp_client_cert_bundle        = "${local.onboarding_secret_path}_pm4mls"
  dfsp_internal_whitelist_secret = "${local.whitelist_secret_path}_pm4mls"
  dfsp_external_whitelist_secret = "${local.whitelist_secret_path}_fsps"

  mcm_fqdn                        = local.mcm_wildcard_gateway == "external" ? "mcm.${var.public_subdomain}" : "mcm.${var.private_subdomain}"
  mcm_istio_gateway_namespace     = local.mcm_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  mcm_istio_wildcard_gateway_name = local.mcm_wildcard_gateway == "external" ? var.istio_external_wildcard_gateway_name : var.istio_internal_wildcard_gateway_name
  mcm_istio_gateway_name          = local.mcm_wildcard_gateway == "external" ? var.istio_external_gateway_name : var.istio_internal_gateway_name
}
