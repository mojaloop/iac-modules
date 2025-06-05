module "generate_netbird_operator_post_config_files" {
  source = "../generate-files"
  var_map = {
    netbird_operator_cluster_name          = "${var.cluster_name}-cluster"
    netbird_operator_post_config_sync_wave = var.netbird_operator_post_config_sync_wave
    netbird_operator_post_config_namespace = var.netbird_operator_post_config_namespace
    netbird_operator_helm_version          = var.netbird_operator_helm_version
    gitlab_project_url                     = var.gitlab_project_url
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
  default     = "-8"
}

variable "netbird_operator_post_config_namespace" {
  type        = string
  description = "netbird_operator_post_config_namespace"
  default     = "netbird-operator-post-config"
}
