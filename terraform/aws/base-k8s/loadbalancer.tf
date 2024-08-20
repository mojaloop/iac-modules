#
# Internal load balancer
#
resource "aws_lb" "internal" { #  for internal traffic, including kube traffic
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = module.base_infra.private_subnets
  tags                             = merge({ Name = "${local.base_domain}-internal" }, local.common_tags)
}

resource "aws_lb_listener" "internal_kubeapi" {
  load_balancer_arn = aws_lb.internal.arn
  port              = var.kubeapi_port
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_kubeapi.arn
  }
}

resource "aws_lb_target_group" "internal_kubeapi" {
  port     = var.kubeapi_port
  protocol = "TCP"
  vpc_id   = module.base_infra.vpc_id
  tags     = merge({ Name = "${local.base_domain}-internal-kubeapi" }, local.common_tags)
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_https.arn
  }
}

resource "aws_lb_target_group" "internal_https" {
  port     = var.target_group_internal_https_port
  protocol = "TCP"
  vpc_id   = module.base_infra.vpc_id

  health_check {
    interval            = 10
    timeout             = 6
    path                = "/healthz/ready"
    port                = var.target_group_internal_health_port
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge({ Name = "${local.base_domain}-internal-https" }, local.common_tags)
}


resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_http.arn
  }
}
resource "aws_lb_target_group" "internal_http" {
  port     = var.target_group_internal_http_port
  protocol = "TCP"
  vpc_id   = module.base_infra.vpc_id

  health_check {
    interval            = 10
    timeout             = 6
    path                = "/healthz/ready"
    port                = var.target_group_internal_health_port
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge({ Name = "${local.base_domain}-internal-http" }, local.common_tags)
}

#
# External load balancer
#


resource "aws_lb" "lb" {
  internal           = false
  load_balancer_type = "network"
  subnets            = module.base_infra.public_subnets
  tags               = merge({ Name = "${local.base_domain}-public" }, local.common_tags)
}

resource "aws_lb_listener" "external_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_https.arn
  }
}

resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_http.arn
  }
}

resource "aws_lb_listener" "wireguard" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.wireguard_port
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard.arn
  }
}

resource "aws_lb_target_group" "external_https" {
  port               = var.target_group_external_https_port
  protocol           = "TCP"
  vpc_id             = module.base_infra.vpc_id
  preserve_client_ip = true
  proxy_protocol_v2  = true

  health_check {
    interval            = 10
    timeout             = 6
    port                = var.target_group_external_https_port
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge({ Name = "${local.base_domain}-external-https" }, local.common_tags)
}

resource "aws_lb_target_group" "external_http" {
  port               = var.target_group_external_http_port
  protocol           = "TCP"
  vpc_id             = module.base_infra.vpc_id
  preserve_client_ip = true
  proxy_protocol_v2  = true

  health_check {
    interval            = 10
    timeout             = 6
    port                = var.target_group_external_http_port
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.base_domain}-external-http" }, local.common_tags)
}


resource "aws_lb_target_group" "wireguard" {
  port     = var.wireguard_port
  protocol = "UDP"
  vpc_id   = module.base_infra.vpc_id

  # TODO: can't health check against a UDP port, but need to have a health check when backend is an instance. 
  # check tcp port 80 (ingress) for now, but probably need to add a http sidecar or something to act as a health check for wireguard
  health_check {
    protocol = "TCP"
    port     = var.target_group_external_https_port
  }

  tags = merge({ Name = "${local.base_domain}-wireguard" }, local.common_tags)
}
