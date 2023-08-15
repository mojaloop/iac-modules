

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}

output "secrets_var_map" {
  sensitive = true
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.password_key_name => data.aws_secretsmanager_secret_version.rds_passwords[index].secret_string
  }
}

output "properties_var_map" {
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.endpoint_key_name => rds_module.db_instance_endpoint
  }
}

output "secrets_key_map" {
  value = {
    for index, rds_module in module.rds : 
      var.rds_services[index].external_resource_config.password_key_name => var.rds_services[index].external_resource_config.password_key_name
  }
}