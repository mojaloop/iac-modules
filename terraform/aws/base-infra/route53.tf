resource "aws_route53_zone" "private" {
  force_destroy = var.route53_zone_force_destroy
  count = var.create_private_zone ? 1 : 0
  name  = "${local.cluster_domain}.internal."

  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = merge({ Name = "${local.cluster_domain}-private" }, local.common_tags)
}

resource "aws_route53_zone" "public" {
  force_destroy = var.route53_zone_force_destroy
  count = var.create_public_zone ? 1 : 0
  name  = "${local.cluster_domain}."
  tags = merge({ Name = "${local.cluster_domain}-public" }, local.common_tags)
}

resource "aws_route53_record" "public_ns" {
  count = var.create_public_zone ? 1 : 0
  zone_id = local.cluster_parent_zone_id
  name    = local.cluster_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public[0].name_servers
}

resource "aws_route53_zone" "cluster_parent" {
  force_destroy = var.route53_zone_force_destroy
  count = var.manage_parent_domain ? 1 : 0
  name  = "${local.cluster_parent_domain}."
  tags = merge({ Name = "${local.cluster_domain}-cluster-parent" }, local.common_tags)
}

resource "aws_route53_record" "cluster_ns" {
  count = (var.manage_parent_domain && var.manage_parent_domain_ns) ? 1 : 0
  zone_id = data.aws_route53_zone.cluster_parent_parent[0].zone_id
  name    = local.cluster_parent_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.cluster_parent[0].name_servers
}