module "generate_hostport_allocator_files" {
  source = "../generate-files"
  var_map = {
    hostport_allocator_version = var.hostport_allocator_version
    gitlab_project_url = var.gitlab_project_url
    hostport_allocator_sync_wave = var.hostport_allocator_sync_wave
  }
  file_list       = [for f in fileset(local.hostport_allocator_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.hostport_allocator_app_file, f))]
  template_path   = local.hostport_allocator_template_path
  output_path     = "${var.output_dir}/hostport-allocator"
  app_file        = local.hostport_allocator_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  hostport_allocator_template_path = "${path.module}/../generate-files/templates/hostport-allocator"
  hostport_allocator_app_file      = "hostport-allocator-app.yaml"
}

variable "hostport_allocator_version" {
  type        = string
  description = "hostport_allocator_version"
  default     = "0.17.0"
}
variable "hostport_allocator_sync_wave" {
  type        = string
  description = "hostport_allocator_sync_wave"
  default     = "-18"
}