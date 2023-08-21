#############################
### Access Control
#############################

resource "aws_security_group" "managed_svcs" {
  count  = length(local.external_services) > 0 ? 1 : 0
  name   = "${var.deployment_name}-managed-svcs"
  vpc_id = module.base_infra[0].vpc_id
  tags   = merge({ Name = "${var.deployment_name}-mgmt-svcs" }, local.common_tags)
}

resource "aws_security_group_rule" "mysql" {
  count             = length(local.rds_services) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.managed_svcs[0].id
  description       = "mysql client access"
}

resource "aws_security_group_rule" "egress_all" {
  count             = length(local.external_services) > 0 ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.managed_svcs[0].id
}
