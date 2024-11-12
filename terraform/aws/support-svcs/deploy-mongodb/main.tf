resource "random_password" "mongodb_passwords" {
  for_each = var.mongodb_services
  length   = 20
  special  = false
}

module "mongodb" {
  for_each = var.mongodb_services
  
  source                          = "../../"
  cluster_size                    = each.value.external_resource_config.cluster_size
  master_username                 = each.value.external_resource_config.master_username
  master_password                 = random_password.mongodb_passwords[each.key].result
  instance_class                  = each.value.external_resource_config.instance_class
  db_port                         = each.value.external_resource_config.db_port
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnets
  #zone_id                         = var.zone_id
  apply_immediately               = each.value.external_resource_config.apply_immediately
  auto_minor_version_upgrade      = each.value.external_resource_config.auto_minor_version_upgrade
  #allowed_security_groups        = var.allowed_security_groups
  allowed_cidr_blocks             = var.allowed_cidr_blocks
  snapshot_identifier             = each.value.external_resource_config.snapshot_identifier
  retention_period                = each.value.external_resource_config.retention_period
  preferred_backup_window         = each.value.external_resource_config.preferred_backup_window
  preferred_maintenance_window    = each.value.external_resource_config.preferred_maintenance_window
  cluster_parameters              = each.value.external_resource_config.cluster_parameters
  cluster_family                  = each.value.external_resource_config.cluster_family
  engine                          = each.value.external_resource_config.engine
  engine_version                  = each.value.external_resource_config.engine_version
  storage_encrypted               = each.value.external_resource_config.storage_encrypted
  kms_key_id                      = var.kms_key_id
  skip_final_snapshot             = each.value.external_resource_config.skip_final_snapshot
  enabled_cloudwatch_logs_exports = each.value.external_resource_config.enabled_cloudwatch_logs_exports

  namespace               = "mongodb"
  stage                   = var.deployment_name
  name                    = each.key
}