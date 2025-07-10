module "generate_crossplane_providers_files" {
  source = "../generate-files"
  var_map = {
    crossplane_provider_config_sync_wave     = var.crossplane_provider_config_sync_wave
    gitlab_project_url                       = var.gitlab_project_url
    crossplane_namespace                     = var.crossplane_namespace
  }
  file_list       = [for f in fileset(local.crossplane_providers_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.crossplane_providers_app_file, f))]
  template_path   = local.crossplane_providers_template_path
  output_path     = "${var.output_dir}/crossplane-provider-config"
  app_file        = local.crossplane_providers_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  crossplane_providers_template_path    = "${path.module}/../generate-files/templates/crossplane-provider-config"
  crossplane_providers_app_file         = "crossplane-providerconfig-app.yaml"
}

variable "crossplane_provider_config_sync_wave" {
  type    = string
  default = "-11"
}