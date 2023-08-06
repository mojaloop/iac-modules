module "generate_mcm_files" {
  source = "./generate-files"
  var_map = {
    db_password_secret             = local.stateful_resources[local.mcm_resource_index].generate_secret_name
    db_password_secret_key         = local.stateful_resources[local.mcm_resource_index].generate_secret_keys[0]
    db_user                        = local.stateful_resources[local.mcm_resource_index].local_resource.mysql_data.user
    db_schema                      = local.stateful_resources[local.mcm_resource_index].local_resource.mysql_data.database_name
    db_port                        = local.stateful_resources[local.mcm_resource_index].logical_service_port
    db_host                        = "${local.stateful_resources[local.mcm_resource_index].logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    mcm_public_fqdn                = "mcm.${var.public_subdomain}"
    env_name                       = var.cluster_name
    env_cn                         = var.public_subdomain
    env_o                          = "Mojaloop"
    env_ou                         = "Infra"
    storage_class_name             = var.storage_class_name
    server_cert_secret_name        = var.vault_certman_secretname
    server_cert_secret_namespace   = var.mcm_namespace
    oauth_key                      = var.mcm_oidc_client_id
    oauth_secret_secret            = var.mcm_oauth_secret_secret
    oauth_secret_secret_key        = var.mcm_oauth_secret_secret_key
    switch_domain                  = var.public_subdomain
    vault_endpoint                 = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    pki_base_domain                = var.public_subdomain
    mcm_chart_repo                 = var.mcm_chart_repo
    mcm_chart_version              = var.mcm_chart_version
    mcm_namespace                  = var.mcm_namespace
    gitlab_project_url             = var.gitlab_project_url
    public_subdomain               = var.public_subdomain
    enable_oidc                    = var.enable_mcm_oidc
    mcm_sync_wave                  = var.mcm_sync_wave
    ingress_class                  = var.mcm_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    pki_path                       = var.vault_root_ca_name
    dfsp_client_cert_bundle        = "${var.onboarding_secret_name_prefix}_pm4mls"
    dfsp_internal_whitelist_secret = "${var.whitelist_secret_name_prefix}_pm4mls"
    dfsp_external_whitelist_secret = "${var.whitelist_secret_name_prefix}_fsps"
    onboarding_secret_name_prefix  = var.onboarding_secret_name_prefix
    whitelist_secret_name_prefix   = var.whitelist_secret_name_prefix
    mcm_service_account_name       = var.mcm_service_account_name
    pki_client_role                = var.pki_client_cert_role
    pki_server_role                = var.pki_server_cert_role
    mcm_vault_k8s_role_name        = var.mcm_vault_k8s_role_name
    k8s_auth_path                  = var.k8s_auth_path
    mcm_secret_path                = var.mcm_secret_path
    totp_issuer                    = "not-used-yet"
    token_issuer_fqdn              = "keycloak.${var.public_subdomain}"
    istio_namespace                = var.istio_namespace
    nginx_external_namespace       = var.nginx_external_namespace
  }
  file_list       = ["values-mcm.yaml", "kustomization.yaml", "vault-rbac.yaml", "vault-agent.yaml", "configmaps/vault-agent-configmap.yaml"]
  template_path   = "${path.module}/generate-files/templates/mcm"
  output_path     = "${var.output_dir}/mcm"
  app_file        = "mcm-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "mcm_ingress_internal_lb" {
  type        = bool
  description = "mcm_ingress_internal_lb"
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
  default     = "0.6.5"
  description = "mcm_chart_version"
}

variable "mcm_sync_wave" {
  type        = string
  description = "mcm_sync_wave"
  default     = "0"
}

variable "mcm_namespace" {
  type        = string
  description = "mcm_namespace"
  default     = "mcm"
}

variable "onboarding_secret_name_prefix" {
  type        = string
  description = "vault secret prefix for dfsp onboarding entries"
  default     = "secret/onboarding"
}

variable "mcm_service_account_name" {
  type        = string
  description = "service account name for mcm"
  default     = "mcm"
}

variable "mcm_secret_path" {
  description = "vault kv secret path for mcm use"
  type        = string
  default     = "secret/mcm"
}

variable "mcm_vault_k8s_role_name" {
  description = "vault k8s role name for mcm"
  type        = string
  default     = "kubernetes-mcm-role"
}

locals {
  mcm_resource_index = index(local.stateful_resources.*.resource_name, "mcm-db")
}
