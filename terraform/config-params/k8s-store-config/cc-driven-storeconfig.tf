resource "random_password" "db_user_password" {
  for_each         = local.internal_databases
  length           = 30
  special          = true
  override_special = "_"
}

module "config_deepmerge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.2.0"
  maps    = local.stateful_resources_config_vars_list
}

data "vault_kv_secret_v2" "common_platform_db_instance_address" {
  count = var.db_mediated_by_control_center ? 1 : 0
  mount = var.kv_path
  name  = "${var.cluster_name}/common_mojaloop_db_instance_address"
}

data "vault_kv_secret_v2" "common_mojaloop_db_instance_address" {
  count = var.db_mediated_by_control_center ? 1 : 0
  mount = var.kv_path
  name  = "${var.cluster_name}/common_mojaloop_db_instance_address"
}

data "vault_kv_secret_v2" "common_platform_db_instance_password" {
  count = var.db_mediated_by_control_center ? 1 : 0
  mount = var.kv_path
  name  = "${var.cluster_name}/common_mojaloop_db_instance_password"
}

data "vault_kv_secret_v2" "common_mojaloop_db_instance_password" {
  count = var.db_mediated_by_control_center ? 1 : 0
  mount = var.kv_path
  name  = "${var.cluster_name}/common_mojaloop_db_instance_password"
}


locals {
  st_res_managed_vars           = yamldecode(file(var.managed_stateful_resources_config_file))
  plt_st_res_config             = yamldecode(file(var.platform_stateful_resources_config_file))

  stateful_resources_config_vars_list = [local.st_res_managed_vars, local.plt_st_res_config]

  stateful_resources               = module.config_deepmerge.merged
  enabled_stateful_resources       = { for key, stateful_resource in local.stateful_resources : key => stateful_resource if stateful_resource.enabled }

  internal_databases = var.db_mediated_by_control_center ? { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "mysql" } : {}

  internal_db_secret_var_map = { for index, int_database in local.internal_databases : int_database.external_resource_config.password_key_name => random_password.db_user_password[index].result}
  internal_db_properties_var_map = { for index, int_database in local.internal_databases :  int_database.external_resource_config.instance_address_key_name =>
        int_database.external_resource_config.monolith_db_server == "common-platform-db" ? data.vault_kv_secret_v2.common_platform_db_instance_address[0].data.value : data.vault_kv_secret_v2.common_mojaloop_db_instance_address[0].data.value
  }

  internal_db_secrets_key_map = { for index, int_database in var.internal_databases : int_database.external_resource_config.password_key_name => int_database.external_resource_config.password_key_name }

  merged_secrets_key_map = merge(var.secrets_key_map, local.internal_db_secret_key_map)
  merged_secrets_var_map = merge(var.secrets_var_map, local.internal_db_secret_var_map)
  merged_properties_var_map = merge(var.properties_var_map, local.internal_db_properties_var_map)
}