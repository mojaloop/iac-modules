resource "aws_lb" "internal" { #  for internal traffic
  internal                         = true
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = false
  subnets                          = module.base_infra.private_subnets
  tags                             = merge({ Name = "${local.name}-internal" }, local.common_tags)
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.wildcard_cert.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No Host Matched"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "internal_vault" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_vault.arn
  }

  condition {
    host_header {
      values = ["vault.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_listener_rule" "internal_dex" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_dex.arn
  }

  condition {
    host_header {
      values = ["dex.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_target_group" "internal_vault" {
  port               = var.vault_listening_port
  protocol           = "HTTP"
  vpc_id             = module.base_infra.vpc_id
  target_type        = "ip"
  preserve_client_ip = true
  health_check {
    protocol = "HTTP"
    port     = var.vault_listening_port
    path     = "/ui/"
  }

  tags = merge({ Name = "${local.name}-vault-8200" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_vault" {
  target_group_arn = aws_lb_target_group.internal_vault.arn
  target_id        = aws_instance.docker_server.private_ip
  port             = var.vault_listening_port
}

resource "aws_lb_target_group" "internal_dex" {
  port               = var.dex_listening_port
  protocol           = "HTTP"
  vpc_id             = module.base_infra.vpc_id
  target_type        = "ip"
  preserve_client_ip = true
  health_check {
    protocol = "HTTP"
    port     = var.dex_metrics_port
    path     = "/healthz"
  }

  tags = merge({ Name = "${local.name}-dex" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_dex" {
  target_group_arn = aws_lb_target_group.internal_dex.arn
  target_id        = aws_instance.docker_server.private_ip
  port             = var.dex_listening_port
}

resource "aws_acm_certificate" "wildcard_cert" {
  domain_name               = module.base_infra.public_zone.name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${module.base_infra.public_zone.name}", "vault.${module.base_infra.public_zone.name}", "dex.${module.base_infra.public_zone.name}"]
  tags                      = merge({ Name = "${local.name}-wildcard-cert" }, local.common_tags)

  lifecycle {
    create_before_destroy = true
  }
}

# need to set count to 3 for the 3 records (domain name, wildcard and vault, if we add to SAN, need to increment count)
resource "aws_route53_record" "cert_validation" {
  count           = 4
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
