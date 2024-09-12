resource "aws_route53_zone" "private" {
  force_destroy = var.route53_zone_force_destroy
  count         = (var.configure_route_53 && var.create_private_zone) ? 1 : 0
  name          = "${local.cluster_domain}.internal."

  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = merge({ Name = "${local.cluster_domain}-private" }, local.common_tags)
}

resource "aws_route53_zone" "public" {
  force_destroy = var.route53_zone_force_destroy
  count         = (var.configure_route_53 && var.create_public_zone) ? 1 : 0
  name          = "${local.cluster_domain}."
  tags          = merge({ Name = "${local.cluster_domain}-public" }, local.common_tags)
}

resource "aws_route53_zone" "public_int" {
  force_destroy = var.route53_zone_force_destroy
  count         = (var.configure_route_53 && var.create_public_zone) ? 1 : 0
  name          = "${var.private_subdomain_string}.${local.cluster_domain}."
  tags          = merge({ Name = "${local.cluster_domain}-public-int" }, local.common_tags)
}

resource "aws_route53_record" "public_ns" {
  count   = (var.configure_route_53 && var.create_public_zone) ? 1 : 0
  zone_id = local.cluster_parent_zone_id
  name    = local.cluster_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public[0].name_servers
}

resource "aws_route53_record" "public_int_ns" {
  count   = (var.configure_route_53 && var.create_public_zone) ? 1 : 0
  zone_id = aws_route53_zone.public[0].zone_id
  name    = "${var.private_subdomain_string}.${local.cluster_domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public_int[0].name_servers
}

resource "aws_route53_zone" "cluster_parent" {
  force_destroy = var.route53_zone_force_destroy
  count         = (var.configure_route_53 && var.manage_parent_domain) ? 1 : 0
  name          = "${local.cluster_parent_domain}."
  tags          = merge({ Name = "${local.cluster_domain}-cluster-parent" }, local.common_tags)
}

resource "aws_route53_record" "cluster_ns" {
  count   = (var.configure_route_53 && var.manage_parent_domain && var.manage_parent_domain_ns) ? 1 : 0
  zone_id = data.aws_route53_zone.cluster_parent_parent[0].zone_id
  name    = local.cluster_parent_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.cluster_parent[0].name_servers
}

# resource "aws_route53_record" "haproxy_server_private" {
#   count   = (var.configure_route_53 && var.create_haproxy_dns_record) ? 1 : 0
#   zone_id = local.public_zone.id
#   name    = "haproxy"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.bastion.private_ip]
# }

resource "aws_route53_record" "haproxy_server_private" {
  count   = (var.configure_route_53 && var.create_haproxy_dns_record) ? 1 : 0
  zone_id = local.public_zone.id
  name    = "haproxy"
  type    = "A"
  ttl     = "300"
  records = [
    data.aws_instances.bastion_instances.private_ips[0],
    data.aws_instances.bastion_instances.private_ips[1]
  ]
}