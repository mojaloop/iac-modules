data "aws_route53_zone" "public" {
  count = (var.create_public_zone || !var.configure_route_53) ? 0 : 1
  name  = "${local.cluster_domain}."
}

data "aws_route53_zone" "public_int" {
  count = (var.create_public_zone || !var.configure_route_53) ? 0 : 1
  name  = "${var.private_subdomain_string}.${local.cluster_domain}."
}

data "aws_route53_zone" "private" {
  count = (var.create_private_zone || !var.configure_route_53) ? 0 : 1
  name  = "${local.cluster_domain}.internal."
}

data "aws_route53_zone" "cluster_parent" {
  count = (var.manage_parent_domain || !var.configure_route_53) ? 0 : 1
  name  = "${local.cluster_parent_domain}."
}

data "aws_route53_zone" "cluster_parent_parent" {
  count = (var.manage_parent_domain && var.manage_parent_domain_ns && var.configure_route_53) ? 1 : 0
  name  = "${local.cluster_parent_parent_domain}."
}

data "aws_availability_zones" "available" {
  state = "available"
}
