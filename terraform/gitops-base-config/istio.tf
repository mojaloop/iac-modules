module "generate_istio_files" {
  source = "./generate-files"
  var_map = {
    istio_namespace     = var.istio_namespace
    gitlab_project_url  = var.gitlab_project_url
    istio_sync_wave     = var.istio_sync_wave
    istio_chart_repo    = var.istio_chart_repo
    istio_chart_version = var.istio_chart_version
    gateway_api_version = var.gateway_api_version
  }
  file_list       = ["kustomization.yaml", "namespace.yaml", "values-istio-base.yaml", "values-istio-istiod.yaml"]
  template_path   = "${path.module}/generate-files/templates/istio"
  output_path     = "${var.output_dir}/istio"
  app_file        = "istio-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}


variable "istio_chart_repo" {
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
  description = "istio_chart_repo"
}

variable "istio_chart_version" {
  type        = string
  default     = "1.18.2"
  description = "istio_chart_version"
}

variable "gateway_api_version" {
  type        = string
  default     = "v0.7.1"
  description = "gateway_api_version"
}

variable "istio_sync_wave" {
  type        = string
  description = "istio_sync_wave"
  default     = "-8"
}

variable "istio_namespace" {
  type        = string
  description = "istio_namespace"
  default     = "istio-system"
}
