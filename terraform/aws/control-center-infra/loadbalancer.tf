resource "aws_lb" "internal" { #  for internal traffic
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = module.base_infra.private_subnets
  tags                             = merge({ Name = "${local.name}-internal" }, local.common_tags)
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.wildcard_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_vault.arn
  }
}

resource "aws_lb_target_group" "internal_vault" {
  port     = var.vault_listening_port
  protocol = "TCP"
  vpc_id   = module.base_infra.vpc_id
  target_type = "ip"
  health_check {
    protocol = "TCP"
    port     = var.vault_listening_port
  }

  tags = merge({ Name = "${local.name}-vault-8200" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_vault" {
  target_group_arn = aws_lb_target_group.internal_vault.arn
  target_id        = aws_instance.docker_server.id
  port             = 8200
}

resource "aws_acm_certificate" "wildcard_cert" {
  domain_name               = module.base_infra.public_zone.name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${module.base_infra.public_zone.name}", "vault.${module.base_infra.public_zone.name}"]
  tags                      = merge({ Name = "${local.name}-wildcard-cert" }, local.common_tags)

  lifecycle {
    create_before_destroy = true
  }
}

# need to set count to 3 for the 3 records (domain name, wildcard and vault, if we add to SAN, need to increment count)
resource "aws_route53_record" "cert_validation" {
  count           = 3
  name            = aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_name[count.index]
  records         = [aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_value[count.index]]
  type            = aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_type[count.index]
  ttl             = 60
  allow_overwrite = true
  zone_id         = module.base_infra.public_zone.id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.wildcard_cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}
