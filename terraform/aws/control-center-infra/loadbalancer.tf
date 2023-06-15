resource "aws_lb" "internal" { #  for internal traffic
  internal           = true
  load_balancer_type = "network"
  enable_cross_zone_load_balancing = true
  subnets            = module.base_infra.private_subnets
  tags = merge({ Name = "${local.name}-internal" }, local.common_tags)
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
  port     = 8200
  protocol = "TCP"
  vpc_id   = module.base_infra.vpc_id

  health_check {
    interval            = 10
    timeout             = 6
    path                = "/healthz"
    port                = 8200
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge({ Name = "${local.name}-vault-8200" }, local.common_tags)
}
resource "aws_lb_target_group_attachment" "internal_vault" {
  target_group_arn = aws_lb_target_group.internal_vault.arn
  target_id        = aws_instance.docker_server.id
  port             = 8200
}

resource "aws_acm_certificate" "wildcard_cert" {
  domain_name       = module.base_infra.public_zone.name
  validation_method = "DNS"
  subject_alternative_names = ["*.${module.base_infra.public_zone.name}", aws_route53_record.vault_server_private.fqdn]
  tags = merge({ Name = "${local.name}-wildcard-cert" }, local.common_tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name            = aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_name[0]
  records         = [aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_value[0]]
  type            = aws_acm_certificate.wildcard_cert.domain_validation_options.*.resource_record_type[0]
  ttl             = 60
  allow_overwrite = true
  zone_id  = module.base_infra.public_zone.id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.wildcard_cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}