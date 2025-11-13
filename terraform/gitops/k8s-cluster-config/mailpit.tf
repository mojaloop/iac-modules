moved {
  from = module.generate_mailhog_files[0]
  to   = module.generate_mailpit_files[0]
}

module "generate_mailpit_files" {
  count  = try(var.common_var_map.mailpit_enabled, true) ? 1 : 0
  source = "../generate-files"
  var_map = {
    gitlab_project_url                           = var.gitlab_project_url
    mailpit_namespace                            = var.mailpit_namespace
    mailpit_sync_wave                            = var.mailpit_sync_wave
    mailpit_internal_dns_subdomain               = var.private_subdomain
    mailpit_istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    mailpit_istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    mailpit_istio_internal_gateway_name          = var.istio_internal_gateway_name
    ory_namespace                                = var.ory_namespace
    auth_fqdn                                    = local.auth_fqdn
  }
  file_list       = [for f in fileset(local.mailpit_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.mailpit_app_file, f))]
  template_path   = local.mailpit_template_path
  output_path     = "${var.output_dir}/mailpit"
  app_file        = local.mailpit_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  mailpit_template_path = "${path.module}/../generate-files/templates/mailpit"
  mailpit_app_file      = "mailpit-app.yaml"
}

variable "mailpit_namespace" {
  type        = string
  description = "mailpit_namespace"
  default     = "mailpit"
}

variable "mailpit_sync_wave" {
  type        = string
  description = "mailpit_sync_wave"
  default     = "-9"
}