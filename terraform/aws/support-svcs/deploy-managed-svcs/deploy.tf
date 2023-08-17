module "deploy_rds" {
  count = length(local.rds_services) > 0 ? 1 : 0
  source  = "../deploy-rds"
  deployment_name = var.deployment_name
  tags = var.tags
  rds_services = local.rds_services
}