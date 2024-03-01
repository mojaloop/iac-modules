module "msk" {
  for_each   = var.msk_services
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = each.value.external_resource_config.name
  kafka_version          = each.value.external_resource_config.kafka_version
  number_of_broker_nodes = each.value.external_resource_config.number_of_broker_nodes
  enhanced_monitoring    = each.value.external_resource_config.enhanced_monitoring

  broker_node_client_subnets = var.private_subnets
  broker_node_storage_info = each.value.external_resource_config.broker_node_storage_info
  broker_node_instance_type   = each.value.external_resource_config.broker_node_instance_type
  broker_node_security_groups = var.security_group_id

  encryption_in_transit_client_broker = each.value.external_resource_config.encryption_in_transit_client_broker
  encryption_in_transit_in_cluster    = each.value.external_resource_config.encryption_in_transit_in_cluster

  configuration_name        = each.value.external_resource_config.configuration_name
  configuration_description = each.value.external_resource_config.configuration_description
  configuration_server_properties = each.value.external_resource_config.configuration_server_properties

  jmx_exporter_enabled    = each.value.external_resource_config.jmx_exporter_enabled
  node_exporter_enabled   = each.value.external_resource_config.node_exporter_enabled
  cloudwatch_logs_enabled = each.value.external_resource_config.cloudwatch_logs_enabled
  //s3_logs_enabled         = each.value.external_resource_config.s3_logs_enabled
  //s3_logs_bucket          = //captured
  //s3_logs_prefix          = //captured

  scaling_max_capacity = each.value.external_resource_config.scaling_max_capacity
  scaling_target_value = each.value.external_resource_config.scaling_target_value

  client_authentication = each.value.external_resource_config.client_authentication

  //create_scram_secret_association = each.value.external_resource_config.create_scram_secret_association
  //scram_secret_association_secret_arn_list = [
  //  aws_secretsmanager_secret.one.arn,
  //  aws_secretsmanager_secret.two.arn,
  //]

  tags = each.value.external_resource_config.tags
}