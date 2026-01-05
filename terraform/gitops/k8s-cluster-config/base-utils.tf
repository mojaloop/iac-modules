module "generate_reflector_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                     = var.gitlab_project_url
    reflector_chart_version                = var.reflector_chart_version
    reloader_chart_version                 = var.reloader_chart_version
    base_utils_namespace                   = var.base_utils_namespace
    base_utils_sync_wave                   = var.base_utils_sync_wave
    external_secret_sync_wave              = var.external_secret_sync_wave
    cloud_platform                        = local.cloud_platform
    k8s_cluster_type                      = local.k8s_cluster_type
    cluster                               = var.app_var_map.cluster

  }
  file_list       = [for f in fileset(local.base_utils_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.base_utils_app_file, f))]
  template_path   = local.base_utils_template_path
  output_path     = "${var.output_dir}/base-utils"
  app_file        = local.base_utils_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  base_utils_template_path               = "${path.module}/../generate-files/templates/base-utils"
  base_utils_app_file                    = "base-utils-app.yaml"
  reloader_repo_url = startswith(var.reloader_repo_url, "oci://") && can(regex("(oci://[^/]+)(.*)", var.reloader_repo_url)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.reloader_repo_url)[0]]}${regex("(oci://[^/]+)(.*)", var.reloader_repo_url)[1]}", var.reloader_repo_url) : try(local.helm_proxy_repos_map[var.reloader_repo_url], var.reloader_repo_url)
  reflector_repo_url = startswith(var.reflector_repo_url, "oci://") && can(regex("(oci://[^/]+)(.*)", var.reflector_repo_url)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.reflector_repo_url)[0]]}${regex("(oci://[^/]+)(.*)", var.reflector_repo_url)[1]}", var.reflector_repo_url) : try(local.helm_proxy_repos_map[var.reflector_repo_url], var.reflector_repo_url)
}

variable "reflector_chart_version" {
  type        = string
  description = "reflector_chart_version"
  default     = "7.0.190"
}

variable "reloader_chart_version" {
  type        = string
  description = "reloader_chart_version"
  default     = "1.0.67"
}

variable "base_utils_namespace" {
  type        = string
  description = "base_utils_namespace"
  default     = "base-utils"
}

variable "base_utils_sync_wave" {
  type        = string
  description = "cert_manager_issuer_sync_wave"
  default     = "-11"
}

variable "reflector_repo_url" {
  type        = string
  description = "reflector_repo_url"
  default = "https://emberstack.github.io/helm-charts"
}

variable "reloader_repo_url" {
  type        = string
  description = "reloader_repo_url"
  default = "https://stakater.github.io/stakater-charts"
}
