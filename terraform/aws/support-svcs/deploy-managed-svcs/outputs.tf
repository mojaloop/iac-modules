

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
      "${local.rds_services[index].resource_name}-password" => data.aws_secretsmanager_secret_version.rds_passwords[index].secret_string
  }
}

output "properties_var_map" {
  value = {
    for index, rds_module in module.rds : 
      "${local.rds_services[index].resource_name}-endpoint" => rds_module.db_instance_endpoint
  }
}