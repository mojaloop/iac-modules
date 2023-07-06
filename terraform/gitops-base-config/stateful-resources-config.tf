resource "local_file" "chart_values" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.local_resource != null }

  content = templatefile("${local.stateful_resources_template_path}/${each.value.local_resource.resource_helm_values_ref}", {
    resource = each.value
  })
  filename = "${local.stateful_resources_output_path}/values-${each.value.local_resource.resource_helm_chart}-${each.value.resource_name}.yaml"
}

resource "local_file" "vault_crs" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.local_resource != null }

  content = templatefile("${local.stateful_resources_template_path}/vault-crs.yaml.tpl", {
    resource = each.value
  })
  filename = "${local.stateful_resources_output_path}/vault-crs-${each.value.local_resource.resource_helm_chart}-${each.value.resource_name}.yaml"
}

resource "local_file" "external_name_services" {
  content  = templatefile("${local.stateful_resources_template_path}/external-name-services.yaml.tpl", { config = local.local_external_name_map })
  filename = "${local.stateful_resources_output_path}/external-name-services.yaml"
}

resource "local_file" "kustomization" {
  content = templatefile("${local.stateful_resources_template_path}/stateful-resources-kustomization.yaml.tpl",
    { stateful_resources           = local.enabled_stateful_resources
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/kustomization.yaml"
}

resource "local_file" "namespace" {
  content = templatefile("${local.stateful_resources_template_path}/namespace.yaml.tpl",
    {
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/namespace.yaml"
}

resource "local_file" "stateful-resources-app-file" {
  content  = templatefile("${local.stateful_resources_template_path}/app/${local.stateful_resources_app_file}.tpl", local.stateful_resources_vars)
  filename = "${local.app_stateful_resources_output_path}/${local.stateful_resources_app_file}"
}

locals {
  stateful_resources_template_path   = "${path.module}/generate-files/templates/stateful-resources"
  stateful_resources_output_path     = "${var.output_dir}/stateful-resources"
  stateful_resources_app_file        = "stateful-resources-app.yaml"
  app_stateful_resources_output_path = "${var.output_dir}/app-yamls"
  stateful_resources                 = jsondecode(file(var.stateful_resources_config_file))
  enabled_stateful_resources         = { for stateful_resource in local.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled }
  local_external_name_map            = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.logical_service_name => stateful_resource.local_resource != null ? (stateful_resource.local_resource.override_service_name != null ? "${stateful_resource.local_resource.override_service_name}.${stateful_resource.resource_namespace}.svc.cluster.local" : "${stateful_resource.resource_name}.${stateful_resource.resource_namespace}.svc.cluster.local") : stateful_resource.external_service.external_endpoint }
  stateful_resources_vars = {
    stateful_resources_namespace = var.stateful_resources_namespace
    gitlab_project_url           = var.gitlab_project_url
  }
}

variable "stateful_resources_config_file" {
  default     = "../config/stateful-resources.json"
  type        = string
  description = "where to pull stateful resources config"
}

variable "stateful_resources_namespace" {
  type        = string
  description = "stateful_resources_namespace"
  default     = "stateful_resources"
}
