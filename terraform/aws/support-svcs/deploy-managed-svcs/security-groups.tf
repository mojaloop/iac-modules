#############################
### Access Control
#############################

resource "aws_security_group" "managed_svcs" {
  name   = "${local.base_domain}-managed-svcs"
  vpc_id = module.base_infra.vpc_id
  tags   = merge({ Name = "${var.deployment_name}-mgmt-svcs" }, local.common_tags)
}

resource "aws_security_group_rule" "mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.managed_svcs.id
  description       = "mysql client access"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.managed_svcs.id
}
