resource "aws_lb" "internal" { #  for internal traffic
  internal                         = true
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  subnets                          = module.base_infra.private_subnets
  tags                             = merge({ Name = "${local.name}-internal" }, local.common_tags)
  security_groups                  = local.all_security_groups
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

resource "aws_lb_target_group" "internal_vault" {
  port        = var.vault_listening_port
  protocol    = "HTTP"
  vpc_id      = module.base_infra.vpc_id
  target_type = "instance"
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
  target_id        = aws_instance.docker_server.id
  port             = var.vault_listening_port
}

resource "aws_lb_listener_rule" "internal_minio_api" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_minio_api.arn
  }

  condition {
    host_header {
      values = ["minio.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_target_group" "internal_minio_api" {
  port        = var.minio_listening_port
  protocol    = "HTTP"
  vpc_id      = module.base_infra.vpc_id
  target_type = "instance"
  health_check {
    protocol = "HTTP"
    port     = var.minio_listening_port
    path     = "/minio/health/live"
  }

  tags = merge({ Name = "${local.name}-minio-api" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_minio_api" {
  target_group_arn = aws_lb_target_group.internal_minio_api.arn
  target_id        = aws_instance.docker_server.id
  port             = var.minio_listening_port
}

resource "aws_lb_listener_rule" "internal_minio_ui" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 97

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_minio_ui.arn
  }

  condition {
    host_header {
      values = ["minio-ui.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_target_group" "internal_minio_ui" {
  port        = var.minio_ui_port
  protocol    = "HTTP"
  vpc_id      = module.base_infra.vpc_id
  target_type = "instance"
  health_check {
    protocol = "HTTP"
    port     = var.minio_listening_port
    path     = "/minio/health/live"
  }

  tags = merge({ Name = "${local.name}-minio-ui" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_minio_ui" {
  target_group_arn = aws_lb_target_group.internal_minio_ui.arn
  target_id        = aws_instance.docker_server.id
  port             = var.minio_ui_port
}

### nexus endpoints

resource "aws_lb_listener_rule" "internal_nexus_repo" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 96

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_nexus_repo.arn
  }

  condition {
    host_header {
      values = ["nexus.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_target_group" "internal_nexus_repo" {
  port        = var.nexus_docker_repo_listening_port
  protocol    = "HTTP"
  vpc_id      = module.base_infra.vpc_id
  target_type = "instance"
  health_check {
    protocol = "HTTP"
    port     = var.nexus_admin_listening_port
    path     = "/service/rest/v1/status"
  }

  tags = merge({ Name = "${local.name}-nexus-repo" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_nexus_repo" {
  target_group_arn = aws_lb_target_group.internal_nexus_repo.arn
  target_id        = aws_instance.docker_server.id
  port             = var.nexus_docker_repo_listening_port
}

resource "aws_lb_listener_rule" "internal_nexus_admin" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 95

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_nexus_admin.arn
  }

  condition {
    host_header {
      values = ["nexus-ui.${module.base_infra.public_zone.name}"]
    }
  }
}

resource "aws_lb_target_group" "internal_nexus_admin" {
  port        = var.nexus_admin_listening_port
  protocol    = "HTTP"
  vpc_id      = module.base_infra.vpc_id
  target_type = "instance"
  health_check {
    protocol = "HTTP"
    port     = var.nexus_admin_listening_port
    path     = "/service/rest/v1/status"
  }

  tags = merge({ Name = "${local.name}-nexus-admin" }, local.common_tags)
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group_attachment" "internal_nexus_admin" {
  target_group_arn = aws_lb_target_group.internal_nexus_admin.arn
  target_id        = aws_instance.docker_server.id
  port             = var.nexus_admin_listening_port
}

### cert config

resource "aws_acm_certificate" "wildcard_cert" {
  domain_name       = module.base_infra.public_zone.name
  validation_method = "DNS"
  subject_alternative_names = ["*.${module.base_infra.public_zone.name}", "vault.${module.base_infra.public_zone.name}",
    "minio.${module.base_infra.public_zone.name}", "minio-ui.${module.base_infra.public_zone.name}",
  "nexus.${module.base_infra.public_zone.name}", "nexus-ui.${module.base_infra.public_zone.name}"]
  tags = merge({ Name = "${local.name}-wildcard-cert" }, local.common_tags)

  lifecycle {
    create_before_destroy = true
  }
}

# need to set count to 3 for the 3 records (domain name, wildcard and vault, if we add to SAN, need to increment count)
resource "aws_route53_record" "cert_validation" {
  count           = 7
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
