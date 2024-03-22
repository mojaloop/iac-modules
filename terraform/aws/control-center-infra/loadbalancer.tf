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
      values = [aws_route53_record.vault_server_private.fqdn]
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
      values = [aws_route53_record.minio_server_api.fqdn]
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
      values = [aws_route53_record.minio_server_ui.fqdn]
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
      values = [aws_route53_record.nexus_server_api.fqdn]
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
      values = [aws_route53_record.nexus_server_ui.fqdn]
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
  validation_method         = "DNS"
  domain_name               = local.domain_name
  subject_alternative_names = local.subject_alternative_names
  tags                      = merge({ Name = "${local.name}-wildcard-cert" }, local.common_tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_records" {
  # Using count instead of for_each like the examples to allow domain names that won't be known until after apply.
  # E.g., a record with a generated random value in it.
  count = local.domain_names_count

  allow_overwrite = true
  name            = local.validation_options_by_index[count.index].name
  records         = [local.validation_options_by_index[count.index].record]
  ttl             = 60
  type            = local.validation_options_by_index[count.index].type
  # This would need updated to include alternative domains in different hosted zones
  zone_id = local.public_hosted_zone.id

  # tags not supported
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.wildcard_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]

  # tags not supported
}

locals {
  domain_list = ["*.${module.base_infra.public_zone.name}", aws_route53_record.vault_server_private.fqdn,
    aws_route53_record.minio_server_api.fqdn, aws_route53_record.minio_server_ui.fqdn,
  aws_route53_record.nexus_server_api.fqdn, aws_route53_record.nexus_server_ui.fqdn]
  domain_names = [
    for domain_name in local.domain_list : domain_name if !can(regex("shouldnevermatch", domain_name))
  ]
  domain_names_count = length(local.domain_list)

  domain_name               = module.base_infra.public_zone.name
  subject_alternative_names = slice(local.domain_names, 1, length(local.domain_names))

  validation_options_by_index = {
    for dvo in aws_acm_certificate.wildcard_cert.domain_validation_options : index(local.domain_names, dvo.domain_name) => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  public_hosted_zone = module.base_infra.public_zone
}
