module "generate_mailhog_files" {
  count  = try(var.common_var_map.mailhog_enabled, true) ? 1 : 0
  source = "../generate-files"
  var_map = {
    gitlab_project_url                           = var.gitlab_project_url
    mailhog_namespace                            = var.mailhog_namespace
    mailhog_sync_wave                            = var.mailhog_sync_wave
    mailhog_internal_dns_subdomain               = var.private_subdomain
    mailhog_istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    mailhog_istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    mailhog_istio_internal_gateway_name          = var.istio_internal_gateway_name
    ory_namespace                                = var.ory_namespace
  }
  file_list       = [for f in fileset(local.mailhog_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.mailhog_app_file, f))]
  template_path   = local.mailhog_template_path
  output_path     = "${var.output_dir}/mailhog"
  app_file        = local.mailhog_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  mailhog_template_path = "${path.module}/../generate-files/templates/mailhog"
  mailhog_app_file      = "mailhog-app.yaml"
}

variable "mailhog_namespace" {
  type        = string
  description = "mailhog_namespace"
  default     = "mailhog"
}

variable "mailhog_sync_wave" {
  type        = string
  description = "mailhog_sync_wave"
  default     = "-9"
}