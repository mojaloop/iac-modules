module "generate_netbird_operator_post_config_files" {
  source = "../generate-files"
  var_map = {
    netbird_operator_cluster_name          = "${var.cluster_name}-cluster"
    netbird_operator_post_config_sync_wave = var.netbird_operator_post_config_sync_wave
    netbird_operator_post_config_namespace = var.netbird_operator_post_config_namespace
    netbird_operator_namespace             = var.netbird_operator_namespace
    netbird_operator_helm_version          = var.netbird_operator_helm_version
    gitlab_project_url                     = var.gitlab_project_url
    # Netbird secret configuration
    netbird_setup_key_secret_name = "netbird-setup-key"
    netbird_setup_key_secret_key  = "setup-key"
    # Netbird vault path configuration
    netbird_setup_key_vault_path = var.netbird_setup_key_vault_path
    netbird_management_url       = var.netbird_operator_management_url
    netbird_setup_key_name       = var.netbird_setup_key_name
    netbird_setup_key_namespace  = var.netbird_setup_key_namespace
    external_secret_sync_wave    = var.external_secret_sync_wave
    netbird_target_labels = var.netbird_target_labels != "" ? [
      for label in split(",", trimspace(var.netbird_target_labels)) : {
        name  = split("=", label)[0]
        value = split("=", label)[1]
      }
    ] : []
    netbird_image_version       = var.netbird_image_version
    kyverno_sync_wave           = var.kyverno_sync_wave
  }

  file_list       = [for f in fileset(local.netbird_operator_post_config_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.netbird_operator_post_config_app_file, f))]
  template_path   = local.netbird_operator_post_config_template_path
  output_path     = "${var.output_dir}/netbird-operator-post-config"
  app_file        = local.netbird_operator_post_config_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  netbird_operator_post_config_template_path = "${path.module}/../generate-files/templates/netbird-operator-post-config"
  netbird_operator_post_config_app_file      = "netbird-operator-post-config-app.yaml"
}

variable "netbird_operator_post_config_sync_wave" {
  type        = string
  description = "netbird_operator_post_config_sync_wave"
  default     = "-16"
}

variable "netbird_operator_post_config_namespace" {
  type        = string
  description = "netbird_operator_post_config_namespace"
  default     = "netbird-operator-post-config"
}
variable "netbird_setup_key_name" {
  type        = string
  description = "Name of the netbird setup key"
  default     = "netbird-setup-key"
}

variable "netbird_setup_key_namespace" {
  type        = string
  description = "Namespace for the netbird setup key"
  default     = "netbird-operator"
}

variable "netbird_setup_key_vault_path" {
  type        = string
  description = "Vault path for the netbird setup key"
}

variable "netbird_target_labels" {
  type        = string
  description = "Comma-delimited list of label selectors in format name=value to match for adding netbird sidecar to pods"
  default     = "app.kubernetes.io/name=argocd-repo-server,app.kubernetes.io/name=vault"
}

