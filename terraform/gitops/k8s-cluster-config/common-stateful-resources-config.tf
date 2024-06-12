module "common_stateful_resources" {
  source                                        = "../stateful-resources"
  stateful_resources_name                       = "common"
  cluster_name                                  = var.cluster_name
  output_dir                                    = var.output_dir
  gitlab_project_url                            = var.gitlab_project_url
  gitlab_server_url                             = var.gitlab_server_url
  current_gitlab_project_id                     = var.current_gitlab_project_id
  stateful_resources_config_file                = var.stateful_resources_config_file
  stateful_resources_namespace                  = var.stateful_resources_namespace
  create_stateful_resources_ns                  = true
  kv_path                                       = var.kv_path
  external_stateful_resource_instance_addresses = local.external_stateful_resource_instance_addresses
  managed_db_host                               = var.managed_db_host
}

variable "stateful_resources_config_file" {
  type = string
}
variable "stateful_resources_namespace" {
  type    = string
  default = "stateful-resources"
}


data "gitlab_project_variable" "external_stateful_resource_instance_address" {
  for_each = local.managed_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
}

locals {
  stateful_resources         = jsondecode(file(var.stateful_resources_config_file))
  enabled_stateful_resources = { for stateful_resource in local.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled }
  managed_stateful_resources = { for managed_resource in local.enabled_stateful_resources : managed_resource.resource_name => managed_resource if managed_resource.external_service }
  external_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.external_stateful_resource_instance_address : address.key => address.value }
}
