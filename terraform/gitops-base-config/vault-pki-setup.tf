module "generate_vault_pki_setup_files" {
  source = "./generate-files"
  var_map = {
    cert_man_vault_cluster_issuer_name    = var.cert_man_vault_cluster_issuer_name
    cert_manager_namespace                = var.cert_manager_namespace
    public_subdomain                      = var.public_subdomain
    whitelist_secret_name_prefix          = var.whitelist_secret_name_prefix
    cert_manager_service_account_name     = var.cert_manager_service_account_name
    gitlab_project_url                    = var.gitlab_project_url
    cert_manager_cluster_issuer_role_name = var.cert_manager_cluster_issuer_role_name
    interop_switch_fqdn                   = local.interop_switch_fqdn
    vault_root_ca_name                    = var.vault_root_ca_name
    pki_server_cert_role                  = var.pki_server_cert_role
    pki_client_cert_role                  = var.pki_client_cert_role
    k8s_auth_path                         = var.k8s_auth_path
    vault_endpoint                        = "http://vault.${var.vault_namespace}.svc.cluster.local:8200"
  }
  file_list       = ["certman-rbac.yaml", "vault-auth-config.yaml"]
  template_path   = "${path.module}/generate-files/templates/vault-pki-setup"
  output_path     = "${var.output_dir}/vault-pki-setup"
  app_file        = "vault-pki-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "vault_certman_secretname" {
  description = "secret name to create for tls offloading via certmanager"
  type        = string
  default     = "vault-tls-cert"
}

variable "cert_man_vault_cluster_issuer_name" {
  description = "certmanager vault cluster issuer name"
  type        = string
  default     = "vault-cluster-issuer"
}

variable "whitelist_secret_name_prefix" {
  description = "vault secret path for whitelist ip values"
  type        = string
  default     = "secret/whitelist"
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
