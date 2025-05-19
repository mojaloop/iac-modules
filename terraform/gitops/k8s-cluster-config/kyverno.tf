module "generate_reflector_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url    = var.gitlab_project_url
    kyverno_namespace     = var.kyverno_namespace
    kyverno_sync_wave     = var.kyverno_sync_wave
    kyverno_chart_version = var.kyverno_chart_version
  }
  file_list       = [for f in fileset(local.kyverno_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.kyverno_app_file, f))]
  template_path   = local.kyverno_template_path
  output_path     = "${var.output_dir}/kyverno"
  app_file        = local.kyverno_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  kyverno_template_path = "${path.module}/../generate-files/templates/kyverno"
  kyverno_app_file      = "kyverno-app.yaml"
}



variable "kyverno_namespace" {
  type        = string
  description = "kyverno_namespace"
  default     = "kyverno"
}

variable "kyverno_sync_wave" {
  type        = string
  description = "kyverno_sync_wave"
  default     = "-11"
}

variable "kyverno_chart_version" {
  type        = string
  description = "kyverno_chart_version"
  default     = "3.3.7"
}
