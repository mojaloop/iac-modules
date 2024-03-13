resource "aws_route53_record" "gitlab_server_public" {
  zone_id = module.base_infra.public_zone.id
  name    = "gitlab"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.gitlab_server.public_dns]
}

resource "aws_route53_zone" "public_netmaker" {
  count         = var.enable_netmaker ? 1 : 0
  force_destroy = var.route53_zone_force_destroy
  name          = "netmaker.${module.base_infra.public_zone.name}"
  tags          = merge({ Name = "${local.name}-public-netmaker" }, local.common_tags)
}

resource "aws_route53_record" "public_netmaker_ns" {
  count   = var.enable_netmaker ? 1 : 0
  zone_id = module.base_infra.public_zone.id
  name    = "netmaker.${module.base_infra.public_zone.name}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public_netmaker[0].name_servers
}

resource "aws_route53_record" "netmaker_dashboard" {
  count   = var.enable_netmaker ? 1 : 0
  zone_id = aws_route53_zone.public_netmaker[0].id
  name    = "dashboard.${aws_route53_zone.public_netmaker[0].name}"
  type    = "A"
  ttl     = "300"
  records = [module.base_infra.netmaker_public_ip]
}

resource "aws_route53_record" "netmaker_api" {
  count   = var.enable_netmaker ? 1 : 0
  zone_id = aws_route53_zone.public_netmaker[0].id
  name    = "api.${aws_route53_zone.public_netmaker[0].name}"
  type    = "A"
  ttl     = "300"
  records = [module.base_infra.netmaker_public_ip]
}

resource "aws_route53_record" "netmaker_broker" {
  count   = var.enable_netmaker ? 1 : 0
  zone_id = aws_route53_zone.public_netmaker[0].id
  name    = "broker.${aws_route53_zone.public_netmaker[0].name}"
  type    = "A"
  ttl     = "300"
  records = [module.base_infra.netmaker_public_ip]
}

resource "aws_route53_record" "netmaker_stun" {
  count   = var.enable_netmaker ? 1 : 0
  zone_id = aws_route53_zone.public_netmaker[0].id
  name    = "stun.${aws_route53_zone.public_netmaker[0].name}"
  type    = "A"
  ttl     = "300"
  records = [module.base_infra.netmaker_public_ip]
}

resource "aws_route53_record" "nexus_server_private" {
  zone_id = module.base_infra.public_zone.id
  name    = "nexus"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.docker_server.private_ip]
}

resource "aws_route53_record" "minio_server_private" {
  zone_id = module.base_infra.public_zone.id
  name    = "minio"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.docker_server.private_ip]
}

resource "aws_route53_record" "vault_server_private" {
  zone_id = module.base_infra.public_zone.id
  name    = "vault"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.internal.dns_name]
}

resource "aws_route53_record" "dex_private" {
  zone_id = module.base_infra.public_zone.id
  name    = "dex"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.internal.dns_name]
}

resource "aws_route53_record" "gitlab_runner_server_private" {
  zone_id = module.base_infra.public_zone.id
  name    = "gitlab_runner"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.docker_server.private_ip]
}
