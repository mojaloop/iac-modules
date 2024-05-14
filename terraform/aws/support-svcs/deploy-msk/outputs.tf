/*
output "secrets_var_map" {
  sensitive = true
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.password_key_name => jsondecode(data.aws_secretsmanager_secret_version.rds_passwords[index].secret_string)["password"]
  }
}*/

output "properties_var_map" {
  value = {
    for index, msk_module in module.msk : 
      var.msk_services[index].external_resource_config.instance_address_key_name => ( var.msk_services[index].encryption_in_transit_client_broker == "PLAINTEXT" )  ? msk_module.bootstrap_brokers_plaintext : msk_module.bootstrap_brokers_tls  
  }
}
