module "deploy_rds" {
  count = length(local.rds_services) > 0 ? 1 : 0
  source  = "../deploy-rds"
  deployment_name = var.deployment_name
  tags = var.tags
  rds_services = local.rds_services
  security_group_id = aws_security_group.managed_svcs[0].id
  private_subnets = module.base_infra[0].private_subnets
}

module "deploy_kafka" {
  count = length(local.kafka_services) > 0 ? 1 : 0
  source  = "../deploy-kafka"
  deployment_name = var.deployment_name
  tags = var.tags
  kafka_services = local.kafka_services
  security_group_id = aws_security_group.managed_svcs[0].id
  private_subnets = module.base_infra[0].private_subnets
}

module "ubuntu_focal_ami" {
  count = length(local.external_services) > 0 ? 1 : 0
  source  = "../../ami-ubuntu"
  release = "20.04"
}

module "base_infra" {
  count = length(local.external_services) > 0 ? 1 : 0
  source  = "../../base-infra"
  cluster_name = var.deployment_name
  tags = var.tags
  vpc_cidr = var.vpc_cidr
  create_public_zone = false
  create_private_zone = false
  manage_parent_domain = false
  manage_parent_domain_ns = false
  az_count = var.az_count
  bastion_ami = module.ubuntu_focal_ami[0].id
  create_haproxy_dns_record = false
  configure_route_53 = false
}