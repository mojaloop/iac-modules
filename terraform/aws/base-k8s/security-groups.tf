#############################
### Access Control
#############################

resource "aws_security_group" "ingress" {
  name   = "${local.base_domain}-ingress"
  vpc_id = module.base_infra.vpc_id
  tags   = merge({ Name = "${local.base_domain}-ingress" }, local.common_tags)
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = var.target_group_external_http_port
  to_port           = var.target_group_external_http_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = var.target_group_external_https_port
  to_port           = var.target_group_external_https_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_health_external" {
  type              = "ingress"
  from_port         = var.target_group_external_health_port
  to_port           = var.target_group_external_health_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_http_internal" {
  type              = "ingress"
  from_port         = var.target_group_internal_http_port
  to_port           = var.target_group_internal_http_port
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_https_internal" {
  type              = "ingress"
  from_port         = var.target_group_internal_https_port
  to_port           = var.target_group_internal_https_port
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_health_internal" {
  type              = "ingress"
  from_port         = var.target_group_internal_health_port
  to_port           = var.target_group_internal_health_port
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_vpn" {
  type              = "ingress"
  from_port         = var.wireguard_port
  to_port           = var.wireguard_port
  protocol          = "UDP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group_rule" "ingress_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress.id
}

resource "aws_security_group" "self" {
  name   = "${local.base_domain}-self"
  vpc_id = module.base_infra.vpc_id
  tags   = merge({ Name = "${local.base_domain}-self" }, local.common_tags)
}

resource "aws_security_group_rule" "self_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "internal_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_master" {
  type              = "ingress"
  from_port         = var.kubeapi_port
  to_port           = var.kubeapi_port
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_https_external" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_http_external" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_https_internal" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

# change to customize db port ?
resource "aws_security_group_rule" "self_dbaccess_internal" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_http_internal" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.self.id
}

resource "aws_security_group_rule" "self_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.self.id
}
