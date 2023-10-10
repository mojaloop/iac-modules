module "generate_reflector_files" {
  source          = "../generate-files"
  file_list       = ["chart/Chart.yaml", "chart/values.yaml"]
  template_path   = "${path.module}/../generate-files/templates/reflector"
  output_path     = "${var.output_dir}/reflector"
  app_file        = "reflector-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
  var_map = {
    gitlab_project_url                           = var.gitlab_project_url
    reflector_chart_repo                         = var.reflector_chart_repo
    reflector_chart_version                      = var.reflector_chart_version
    reflector_namespace                          = var.reflector_namespace
    reflector_sync_wave                          = var.reflector_sync_wave
  }
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