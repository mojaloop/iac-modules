#############################
### VPC
#############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = local.support_service_name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs
  #database_subnets = local.private_subnet_cidrs

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  tags = merge({}, local.common_tags)
  private_route_table_tags = {
    subnet-type = "private-cluster"
  }
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr
  networks = [
    for subnet in concat(local.private_subnets_list, local.public_subnets_list) : {
      name     = subnet
      new_bits = local.azs == 1 ? var.block_size : 3
    }
  ]

}

resource "aws_security_group" "mgmt-svcs" {
  name   = "${local.support_service_name}-mgmt-svcs"
  vpc_id = module.vpc.vpc_id
  tags   = merge({ Name = "${local.support_service_name}-mgmt-svcs" }, local.common_tags)
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mgmt-svcs.id
}

resource "aws_security_group_rule" "mgmt-svcs_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mgmt-svcs.id
  description       = "mysql client access"
}

resource "aws_security_group_rule" "mgmt-svcs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mgmt-svcs.id
}

## Database modules
resource "aws_kms_key" "managed_db_key" {
  description             = "KMS Key used to manage passwords for managed dbs"
  deletion_window_in_days = 10
}

module "rds" {
  for_each   = local.rds_services
  source     = "terraform-aws-modules/rds/aws"

  identifier = each.key

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
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  maintenance_window = each.value.external_resource_config.maintenance_window
  backup_window      = each.value.external_resource_config.backup_window

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = each.value.external_resource_config.monitoring_interval
  monitoring_role_name   = "${each.value.external_resource_config.db_name}-RDSMonitoringRole"
  create_monitoring_role = true

  tags = each.value.external_resource_config.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

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