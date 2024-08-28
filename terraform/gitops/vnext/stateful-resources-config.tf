module "vnext_stateful_resources" {
  source                                        = "../stateful-resources"
  stateful_resources_name                       = "vnext"
  cluster_name                                  = var.cluster_name
  output_dir                                    = var.output_dir
  gitlab_project_url                            = var.gitlab_project_url
  gitlab_server_url                             = var.gitlab_server_url
  current_gitlab_project_id                     = var.current_gitlab_project_id
  stateful_resources                            = local.mojaloop_stateful_resources
  stateful_resources_namespace                  = var.stateful_resources_namespace
  create_stateful_resources_ns                  = false
  kv_path                                       = var.kv_path
  external_stateful_resource_instance_addresses = local.external_stateful_resource_instance_addresses
  managed_db_host                               = var.managed_db_host
  ceph_api_url                                 = var.ceph_api_url
  ceph_percona_backup_bucket                   = var.ceph_percona_backup_bucket
  external_secret_sync_wave                     = var.external_secret_sync_wave
}

variable "stateful_resources_namespace" {
  type    = string
  default = "stateful-resources"
}

variable "ceph_api_url" {
  type        = string
  description = "ceph_api_url"
}

variable "ceph_percona_backup_bucket" {
  type        = string
  description = "ceph_percona_backup_bucket"
}

data "gitlab_project_variable" "external_stateful_resource_instance_address" {
  for_each = local.managed_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
}

locals {
  mojaloop_stateful_resources = { for key, resource in var.platform_stateful_res_config : key => resource if (resource.app_owner == "mojaloop" && resource.enabled )}
  managed_stateful_resources  = { for key, managed_resource in local.mojaloop_stateful_resources :  key => managed_resource if managed_resource.deployment_type == "external"  }
  external_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.external_stateful_resource_instance_address : address.key => address.value }
}
