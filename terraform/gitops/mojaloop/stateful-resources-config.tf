module "mojaloop_stateful_resources" {
  source                                        = "../stateful-resources"
  stateful_resources_name                       = "mojaloop"
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
  object_store_api_url                          = var.object_store_api_url
  object_store_region                           = var.object_store_region
  object_store_percona_backup_bucket            = var.object_store_percona_backup_bucket
  external_secret_sync_wave                     = var.external_secret_sync_wave
  monolith_stateful_resources                   = local.monolith_for_mojaloop_sts_resources
  monolith_external_stateful_resource_instance_addresses = local.monolith_external_stateful_resource_instance_addresses
  deploy_env_monolithic_db                      = var.deploy_env_monolithic_db
  managed_svc_as_monolith                       = var.managed_svc_as_monolith
  cluster                                       = var.app_var_map.cluster
  storage_class_name                            = var.storage_class_name
  cc_name                                       = var.cc_name
  vpc_cidr                                      = var.vpc_cidr
  vpc_id                                        = var.vpc_id
  database_subnets                              = var.database_subnets
  availability_zones                            = var.availability_zones
  cloud_region                                  = var.cloud_region
}

variable "stateful_resources_namespace" {
  type    = string
  default = "stateful-resources"
}

variable "object_store_api_url" {
  type        = string
  description = "object_store_api_url"
}

variable "object_store_region" {
  type        = string
  description = "object_store_region"
}

variable "object_store_percona_backup_bucket" {
  type        = string
  description = "object_store_percona_backup_bucket"
}

data "gitlab_project_variable" "external_stateful_resource_instance_address" {
  for_each = var.deploy_env_monolithic_db ? tomap({}) : local.managed_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
}

data "gitlab_project_variable" "monolith_external_stateful_resource_instance_address" {
  for_each = var.deploy_env_monolithic_db ? tomap({}) : var.monolith_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
}

locals {
  mojaloop_stateful_resources = { for key, resource in var.platform_stateful_res_config : key => resource if (resource.app_owner == "mojaloop" && resource.enabled )}
  monolith_for_mojaloop_sts_resources = { for key, resource in var.monolith_stateful_resources : key => resource if resource.app_owner == "mojaloop" }
  managed_stateful_resources  = { for key, managed_resource in local.mojaloop_stateful_resources :  key => managed_resource if managed_resource.deployment_type == "external"  }
  external_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.external_stateful_resource_instance_address : address.key => address.value if var.deploy_env_monolithic_db == false }
  monolith_external_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.monolith_external_stateful_resource_instance_address : address.key => address.value if var.deploy_env_monolithic_db == false  }
}
