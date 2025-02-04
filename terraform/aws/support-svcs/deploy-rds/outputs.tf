output "secrets_var_map" {
  sensitive = true
  value = 
    var.managed_svc_as_monolith ?
     { for index, int_database in var.monolith_internal_databases : 
       int_database.external_resource_config.password_key_name => random_password.rds_user_password[index].result
     }
    :{
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.password_key_name => rds_module.db_instance_master_user_password
  }
}

output "properties_var_map" {
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.instance_address_key_name => rds_module.db_instance_address
  }
}

output "secrets_key_map" {
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.password_key_name => var.rds_services[index].external_resource_config.password_key_name
  }
}