## Database modules

/*
resource "aws_kms_key" "managed_db_key" {
  description             = "KMS Key used to manage passwords for managed dbs"
  deletion_window_in_days = 10
}
*/

module "msk_kafka_cluster" {
  for_each   = var.kafka_services
  source     = "terraform-aws-modules/msk-kafka-cluster/aws"

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
  vpc_security_group_ids = [var.security_group_id]

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



module "msk_kafka_cluster" {
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = local.name
  kafka_version          = "3.4.0"
  number_of_broker_nodes = 3
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

  broker_node_client_subnets = ["subnet-12345678", "subnet-024681012", "subnet-87654321"]
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = 100 }
  }
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = ["sg-12345678"]

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  configuration_name        = "example-configuration"
  configuration_description = "Example configuration"
  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = true
  s3_logs_enabled         = true
  s3_logs_bucket          = "aws-msk-kafka-cluster-logs"
  s3_logs_prefix          = local.name

  scaling_max_capacity = 512
  scaling_target_value = 80

  client_authentication = {
    sasl = { scram = true }
  }
  create_scram_secret_association = true
  scram_secret_association_secret_arn_list = [
    aws_secretsmanager_secret.one.arn,
    aws_secretsmanager_secret.two.arn,
  ]

  # AWS Glue Registry
  schema_registries = {
    team_a = {
      name        = "team_a"
      description = "Schema registry for Team A"
    }
    team_b = {
      name        = "team_b"
      description = "Schema registry for Team B"
    }
  }

  # AWS Glue Schemas
  schemas = {
    team_a_tweets = {
      schema_registry_name = "team_a"
      schema_name          = "tweets"
      description          = "Schema that contains all the tweets"
      compatibility        = "FORWARD"
      schema_definition    = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
      tags                 = { Team = "Team A" }
    }
    team_b_records = {
      schema_registry_name = "team_b"
      schema_name          = "records"
      description          = "Schema that contains all the records"
      compatibility        = "FORWARD"
      team_b_records = {
        schema_registry_name = "team_b"
        schema_name          = "records"
        description          = "Schema that contains all the records"
        compatibility        = "FORWARD"
        schema_definition = jsonencode({
          type = "record"
          name = "r1"
          fields = [
            {
              name = "f1"
              type = "int"
            },
            {
              name = "f2"
              type = "string"
            },
            {
              name = "f3"
              type = "boolean"
            }
          ]
        })
        tags = { Team = "Team B" }
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}