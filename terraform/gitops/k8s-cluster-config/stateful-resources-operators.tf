module "generate_stateful_resources_operators" {
  source = "../generate-files"
  var_map = {
    cluster_name                           = var.cluster_name
    output_dir                             = var.output_dir
    gitlab_project_url                     = var.gitlab_project_url
    gitlab_server_url                      = var.gitlab_server_url
    current_gitlab_project_id              = var.current_gitlab_project_id
    stateful_resources_operators           = local.enabled_stateful_resources_operators
    stateful_resources_operators_ns        = local.enabled_stateful_resources_operators_ns
    stateful_resources_operators_namespace = var.stateful_resources_operators_namespace
    stateful_resources_operators_sync_wave = var.stateful_resources_operators_sync_wave
    create_stateful_resources_ns           = true
    kv_path                                = var.kv_path
  }
  file_list       = [for f in fileset(local.stateful_resources_operators_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.stateful_resources_operators_app_file, f))]
  template_path   = local.stateful_resources_operators_template_path
  output_path     = "${var.output_dir}/stateful-resources-operators"
  app_file        = local.stateful_resources_operators_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "stateful_resources_operators_config_file" {
  type = string
}

variable "stateful_resources_operators_namespace" {
  type    = string
  default = "stateful-resources-operators"
}

variable "stateful_resources_operators_sync_wave" {
  type        = string
  description = "stateful_resources_sync_wave, can go before vault as does not need secrets"
  default     = "-6"
}


locals {
  stateful_resources_operators_template_path = "${path.module}/../generate-files/templates/stateful-resources-operators"
  stateful_resources_operators_app_file      = "stateful-resources-operators-app.yaml"
  stateful_resources_operators               = yamldecode(file(var.stateful_resources_operators_config_file))
  enabled_stateful_resources_operators       = { for key, operator in local.stateful_resources_operators : key => operator if operator.enabled }
  enabled_stateful_resources_operators_ns    = distinct([for operator in local.enabled_stateful_resources_operators : operator.namespace])
}
