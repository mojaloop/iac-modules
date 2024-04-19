module "generate_vault_pki_setup_files" {
  source = "../generate-files"
  var_map = {
    cert_man_vault_cluster_issuer_name    = var.cert_man_vault_cluster_issuer_name
    cert_manager_namespace                = var.cert_manager_namespace
    public_subdomain                      = var.public_subdomain
    whitelist_secret_name_prefix          = local.whitelist_secret_path
    onboarding_secret_name_prefix         = local.onboarding_secret_path
    cert_manager_service_account_name     = var.cert_manager_service_account_name
    gitlab_project_url                    = var.gitlab_project_url
    cert_manager_cluster_issuer_role_name = var.cert_manager_cluster_issuer_role_name
    interop_switch_fqdn                   = var.external_interop_switch_fqdn
    vault_root_ca_name                    = var.vault_root_ca_name
    pki_server_cert_role                  = var.pki_server_cert_role
    pki_client_cert_role                  = var.pki_client_cert_role
    k8s_auth_path                         = var.k8s_auth_path
    vault_endpoint                        = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
    vault_pki_sync_wave                   = var.vault_pki_sync_wave
  }
  file_list       = [for f in fileset(local.vault_pki_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.vault_pki_app_file, f))]
  template_path   = local.vault_pki_template_path
  output_path     = "${var.output_dir}/vault-pki-setup"
  app_file        = local.vault_pki_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  vault_pki_template_path              = "${path.module}/../generate-files/templates/vault-pki-setup"
  vault_pki_app_file                   = "vault-pki-app.yaml"
}



variable "cert_man_vault_cluster_issuer_name" {
  description = "certmanager vault cluster issuer name"
  type        = string
  default     = "vault-cluster-issuer"
}

variable "local_vault_kv_root_path" {
  description = "vault kv secret root"
  type        = string
}

variable "cert_manager_cluster_issuer_role_name" {
  description = "cert_manager_cluster_issuer_role_name"
  type        = string
  default     = "cert-man-cluster-issuer-role"
}

variable "vault_root_ca_name" {
  description = "root ca name for vault"
  type        = string
  default     = "pki-root-ca"
}
variable "pki_client_cert_role" {
  description = "pki_client_cert_role"
  default     = "client-cert-role"
}

variable "pki_server_cert_role" {
  description = "pki_server_cert_role"
  default     = "server-cert-role"
}

variable "k8s_auth_path" {
  description = "k8s_auth_path"
  default     = "kubernetes"
}

variable "vault_pki_sync_wave" {
  type        = string
  description = "vault_pki_sync_wave"
  default     = "-5"
}

locals {
  whitelist_secret_path  = "${var.local_vault_kv_root_path}/whitelist"
  onboarding_secret_path = "${var.local_vault_kv_root_path}/onboarding"
  mcm_secret_path        = "${var.local_vault_kv_root_path}/mcm"
}
