resource "aws_kms_key" "managed_db_key" {
  for_each = {
    for key, value in var.mongodb_services : key => value
    if value.external_resource_config.storage_encrypted
  }
  description             = "KMS Key used to manage passwords for managed dbs"
  deletion_window_in_days = 10
}

module "mongodb" {
  for_each = var.mongodb_services
  
  source                          = "cloudposse/documentdb-cluster/aws"
  version                         = "v0.26.2"
  cluster_size                    = each.value.external_resource_config.cluster_size
  master_username                 = each.value.external_resource_config.username
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
  kms_key_id                      = each.value.external_resource_config.storage_encrypted ? aws_kms_key.managed_db_key[each.key].arn : ""
  skip_final_snapshot             = each.value.external_resource_config.skip_final_snapshot
  enabled_cloudwatch_logs_exports = each.value.external_resource_config.enabled_cloudwatch_logs_exports

  namespace               = "docdb"
  stage                   = var.deployment_name
  name                    = each.key
}