output "secrets_var_map" {
  sensitive = true
  value = {
    for index, mongodb_module in module.mongodb : 
      var.mongodb_services[index].external_resource_config.password_key_name => mongodb_module.master_password
  }
}

output "properties_var_map" {
  value = {
    for index, mongodb_module in module.mongodb : 
      var.mongodb_services[index].external_resource_config.instance_address_key_name => mongodb_module.endpoint
  }
}

output "secrets_key_map" {
  value = {
    for index, mongodb_module in module.mongodb : 
      var.mongodb_services[index].external_resource_config.password_key_name => var.mongodb_services[index].external_resource_config.password_key_name
  }
}