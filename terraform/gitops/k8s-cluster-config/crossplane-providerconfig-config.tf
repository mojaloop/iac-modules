module "generate_crossplane_providerconfig_files" {
  source = "../generate-files"
  var_map = {
    crossplane_provider_config_sync_wave     = var.crossplane_provider_config_sync_wave
    gitlab_project_url                       = var.gitlab_project_url
    crossplane_namespace                     = var.crossplane_namespace
    cloud_provider                           = var.cloud_platform
  }
  file_list       = [for f in fileset(local.crossplane_providerconfig_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.crossplane_providerconfig_app_file, f))]
  template_path   = local.crossplane_providerconfig_template_path
  output_path     = "${var.output_dir}/crossplane-provider-config"
  app_file        = local.crossplane_providerconfig_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  crossplane_providerconfig_template_path    = "${path.module}/../generate-files/templates/crossplane-provider-config"
  crossplane_providerconfig_app_file         = "crossplane-providerconfig-app.yaml"
}

variable "crossplane_provider_config_sync_wave" {
  type    = string
  default = "-11"
}