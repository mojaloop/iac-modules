module "generate_reflector_files" {
  source          = "../generate-files"
  var_map = {
    gitlab_project_url                           = var.gitlab_project_url
    reflector_chart_repo                         = var.reflector_chart_repo
    reflector_chart_version                      = var.reflector_chart_version
    reflector_namespace                          = var.reflector_namespace
    reflector_sync_wave                          = var.reflector_sync_wave
  }
  file_list       = [for f in fileset(local.reflector_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.reflector_app_file, f))]
  template_path   = local.reflector_template_path
  output_path     = "${var.output_dir}/reflector"
  app_file        = local.reflector_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  reflector_template_path              = "${path.module}/../generate-files/templates/reflector"
  reflector_app_file                   = "reflector-app.yaml"
}
variable "reflector_chart_repo" {
  type        = string
  description = "reflector_chart_repo"
  default     = "https://emberstack.github.io/helm-charts"
}
variable "reflector_chart_version" {
  type        = string
  description = "reflector_chart_version"
  default = "7.0.190"
}

variable "reflector_namespace" {
  type        = string
  description = "reflector_namespace"
  default     = "reflector"
}

variable "reflector_sync_wave" {
  type        = string
  description = "cert_manager_issuer_sync_wave"
  default     = "-11"
}