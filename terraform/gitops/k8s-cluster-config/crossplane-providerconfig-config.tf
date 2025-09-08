module "generate_crossplane_providerconfig_files" {
  source = "../generate-files"
  var_map = {
    crossplane_provider_config_sync_wave     = var.crossplane_provider_config_sync_wave
    gitlab_project_url                       = var.gitlab_project_url
    crossplane_namespace                     = var.crossplane_namespace
    cloud_provider                           = var.cloud_platform
    sc_api_server                            = "${var.cluster_name}/sc_api_server"
    sc_api_ca                                = "${var.cluster_name}/sc_api_ca"
    sc_api_token                             = "${var.cluster_name}/sc_api_token"
    cluster_name                             = var.cluster_name
    external_secret_sync_wave                = var.external_secret_sync_wave
    sc_api_host                              = var.sc_api_host
    sc_api_port                              = var.sc_api_port
    istio_nb_egress_waypoint_name            = var.istio_nb_egress_waypoint_name
    istio_nb_egress_waypoint_namespace       = var.istio_nb_egress_waypoint_namespace
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

variable "sc_api_port" {
  type    = integer
  description = "Port for the SC API server"
}
variable "sc_api_host" {
  type    = string
  description = "Host for the SC API server"
}