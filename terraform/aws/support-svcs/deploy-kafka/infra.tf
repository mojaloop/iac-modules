module "msk_kafka_cluster" {
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = each.value.external_resource_config.name
  kafka_version          = each.value.external_resource_config.kafka_version
  number_of_broker_nodes = each.value.external_resource_config.number_of_broker_nodes
  enhanced_monitoring    = each.value.external_resource_config.enhanced_monitoring

  broker_node_client_subnets = ["subnet-12345678", "subnet-024681012", "subnet-87654321"]
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = 100 }
  }
  broker_node_instance_type   = each.value.external_resource_config.broker_node_instance_type
  broker_node_security_groups = ["sg-12345678"]

  encryption_in_transit_client_broker = each.value.external_resource_config.encryption_in_transit_client_broker
  encryption_in_transit_in_cluster    = each.value.external_resource_config.encryption_in_transit_in_cluster

  configuration_name        = each.value.external_resource_config.configuration_name
  configuration_description = each.value.external_resource_config.configuration_description
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