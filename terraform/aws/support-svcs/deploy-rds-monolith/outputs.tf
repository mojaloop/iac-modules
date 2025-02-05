output "secrets_var_map" {
  sensitive = true
  value =  { for index, int_database in var.monolith_internal_databases : int_database.external_resource_config.password_key_name => random_password.rds_user_password[index].result}
}

output "properties_var_map" {
  value = {
    for index, int_database in var.monolith_internal_databases : 
      int_database.external_resource_config.instance_address_key_name => module.rds[int_database.external_resource_config.monolith_db_server].db_instance_address
  }
}

output "secrets_key_map" {
  value = {
    for index, int_database in var.monolith_internal_databases : 
      int_database.external_resource_config.password_key_name => int_database.external_resource_config.password_key_name
  }
}