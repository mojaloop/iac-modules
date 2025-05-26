module "config_deepmerge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.2.0"
  maps    = local.stateful_resources_config_vars_list
}

module "deploy_rds_ms" {
  count = length(local.rds_services) > 0 && var.managed_svc_as_monolith == false ? 1 : 0
  source  = "../deploy-rds-ms"
  deployment_name = var.deployment_name
  tags = var.tags
  rds_services = local.rds_services
  security_group_id = aws_security_group.managed_svcs[0].id
  private_subnets = module.base_infra[0].private_subnets
  managed_svc_as_monolith = var.managed_svc_as_monolith
  monolith_internal_databases = local.monolith_internal_databases
}

module "deploy_rds_monolith" {
  count = length(local.monolith_rds_services) > 0  && var.managed_svc_as_monolith == true ? 1 : 0
  source  = "../deploy-rds-monolith"
  deployment_name = var.deployment_name
  tags = var.tags
  rds_services = local.monolith_rds_services
  security_group_id = aws_security_group.managed_svcs[0].id
  private_subnets = module.base_infra[0].private_subnets
  managed_svc_as_monolith = var.managed_svc_as_monolith
  monolith_internal_databases = local.monolith_internal_databases
}

module "deploy_msk" {
  count = length(local.msk_services) > 0 ? 1 : 0
  source  = "../deploy-msk"
  deployment_name = var.deployment_name
  tags = var.tags
  msk_services = local.msk_services
  security_group_id = aws_security_group.managed_svcs.*.id
  private_subnets = module.base_infra[0].private_subnets
}

module "deploy_mongodb" {
  count             = length(local.mongodb_services) > 0 ? 1 : 0
  source            = "../deploy-mongodb"
  deployment_name   = var.deployment_name
  mongodb_services  = local.mongodb_services
  
  private_subnets      = module.base_infra[0].private_subnets
  allowed_cidr_blocks  = ["0.0.0.0/0"]
  vpc_id               = module.base_infra[0].vpc_id
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
  bastion_asg_config = {
    name             = "bastion"
    desired_capacity = var.bastion_instance_number
    max_size         = var.bastion_instance_number
    min_size         = var.bastion_instance_number
    instance_type    = var.bastion_instance_size
  }
}