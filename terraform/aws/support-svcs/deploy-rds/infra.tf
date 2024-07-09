## Database modules
resource "aws_kms_key" "managed_db_key" {
  description             = "KMS Key used to manage passwords for managed dbs"
  deletion_window_in_days = 10
}

module "rds" {
  for_each   = var.rds_services
  source     = "terraform-aws-modules/rds/aws"

  identifier = "${var.deployment_name}-${each.key}"

  engine              = each.value.external_resource_config.engine
  engine_version      = each.value.external_resource_config.engine_version
  instance_class      = each.value.external_resource_config.instance_class
  allocated_storage   = each.value.external_resource_config.allocated_storage
  storage_encrypted   = each.value.external_resource_config.storage_encrypted
  multi_az            = each.value.external_resource_config.multi_az
  skip_final_snapshot = each.value.external_resource_config.skip_final_snapshot

  db_name  = each.value.external_resource_config.db_name
  username = each.value.external_resource_config.username
  port     = each.value.external_resource_config.port
  master_user_secret_kms_key_id = aws_kms_key.managed_db_key.key_id
  vpc_security_group_ids = [var.security_group_id]

  maintenance_window = each.value.external_resource_config.maintenance_window
  backup_window      = each.value.external_resource_config.backup_window

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = each.value.external_resource_config.monitoring_interval
  monitoring_role_name   = "${var.deployment_name}-${each.value.external_resource_config.db_name}-RDSMonitoringRole"
  create_monitoring_role = true

  tags = each.value.external_resource_config.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.private_subnets

  # DB parameter group
  family = each.value.external_resource_config.family

  # DB option group
  major_engine_version = each.value.external_resource_config.major_engine_version

  # Database Deletion Protection
  deletion_protection = each.value.external_resource_config.deletion_protection

  parameters = each.value.external_resource_config.parameters

  options = each.value.external_resource_config.options
}

data "aws_secretsmanager_secret" "rds_passwords" {
  for_each = module.rds
  arn = each.value.db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_passwords" {
  for_each = data.aws_secretsmanager_secret.rds_passwords
  secret_id     = each.value.id
}