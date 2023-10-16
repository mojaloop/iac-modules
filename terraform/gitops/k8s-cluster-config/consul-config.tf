module "generate_consul_files" {
  source = "../generate-files"
  var_map = {
    consul_chart_repo          = var.consul_chart_repo
    consul_chart_version       = var.common_var_map.consul_chart_version
    consul_namespace           = var.consul_namespace
    storage_class_name         = var.storage_class_name
    storage_size               = var.consul_storage_size
    consul_replicas            = var.consul_replicas
    gitlab_project_url         = var.gitlab_project_url
    consul_sync_wave           = var.consul_sync_wave
  }
  file_list       = ["Chart.yaml", "values.yaml"]
  template_path   = "${path.module}/../generate-files/templates/consul"
  output_path     = "${var.output_dir}/consul"
  app_file        = "consul-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "consul_chart_repo" {
  type        = string
  description = "consul_chart_repo"
  default     = "https://helm.releases.hashicorp.com"
}

variable "consul_replicas" {
  type        = string
  description = "consul_replicas"
  default     = "1"
}

variable "consul_storage_size" {
  type        = string
  description = "storage_size"
  default     = "3Gi"
}

variable "consul_namespace" {
  type        = string
  description = "consul_namespace"
  default     = "consul"
}

variable "consul_sync_wave" {
  type        = string
  description = "consul_sync_wave"
  default     = "-9"
}