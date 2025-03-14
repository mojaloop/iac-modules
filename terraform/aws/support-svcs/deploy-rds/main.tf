locals {
  is_aurora = try(regex("aurora", var.engine),"") == "aurora" ? true : false
}

module "db_subnet_group" {
  source = "terraform-aws-modules/rds/aws//modules/db_subnet_group"

  create = var.create

  name            = coalesce(var.db_subnet_group_name, var.identifier)
  use_name_prefix = var.db_subnet_group_use_name_prefix
  description     = var.db_subnet_group_description
  subnet_ids      = var.subnet_ids

  tags = merge(var.tags, var.db_subnet_group_tags)
}



resource "aws_rds_cluster_parameter_group" "default" {
  name        = coalesce(var.parameter_group_name, var.identifier)
  family      = var.family
  description = coalesce(var.parameter_group_name, var.identifier)

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = coalesce(var.parameter_group_name, var.identifier)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "rds_master_password" {
  length           = 30
  special          = true
  override_special = "_"
}

resource "aws_rds_cluster" "rds_cluster" {
  count = var.create ? 1 : 0

  cluster_identifier = var.identifier

  engine                    = var.engine
  engine_version            = var.engine_version
  db_cluster_instance_class = local.is_aurora ?  null : var.instance_class
  allocated_storage         = local.is_aurora ?  null : var.allocated_storage
  storage_type              = local.is_aurora ?  null : var.storage_type
  iops                      = local.is_aurora ?  null : var.iops
  storage_encrypted         = var.storage_encrypted
  kms_key_id                = var.kms_key_id

  database_name   = var.db_name
  master_username = var.username
  master_password = random_password.rds_master_password.result
  port            = var.port

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = module.db_subnet_group.db_subnet_group_id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.id

  network_type = var.network_type



  allow_major_version_upgrade  = var.allow_major_version_upgrade
  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.maintenance_window

  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier_prefix

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection = var.deletion_protection

  tags = var.tags

}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = local.is_aurora ? var.replicas : 0
  identifier         = "${var.identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds_cluster[0].engine
  engine_version     = aws_rds_cluster.rds_cluster[0].engine_version
}