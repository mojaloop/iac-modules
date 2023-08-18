module "vpc_netmaker" {
  count   = var.enable_netmaker ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.cluster_name}-netmaker"
  cidr = var.netmaker_vpc_cidr

  azs            = [local.azs[0]]
  public_subnets = [module.netmaker_subnet_addrs[0].network_cidr_blocks["netmaker-public"]]

  create_database_subnet_group = false

  enable_dns_hostnames          = true
  enable_dns_support            = true
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false

  tags = merge({}, local.common_tags)

}

module "netmaker_subnet_addrs" {
  count  = var.enable_netmaker ? 1 : 0
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.netmaker_vpc_cidr
  networks = [
    {
      name     = "netmaker-public"
      new_bits = 1
    },
  ]

}

resource "aws_security_group" "netmaker" {
  count  = var.enable_netmaker ? 1 : 0
  name   = "${local.cluster_domain}-netmaker"
  vpc_id = module.vpc_netmaker[0].vpc_id
  tags   = merge({ Name = "${local.cluster_domain}-netmaker" }, local.common_tags)
}

resource "aws_security_group_rule" "netmaker_ssh" {
  count             = var.enable_netmaker ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netmaker[0].id
  description       = "ssh  access"

}

resource "aws_security_group_rule" "netmaker_wireguard" {
  count             = var.enable_netmaker ? 1 : 0
  type              = "ingress"
  from_port         = 51820
  to_port           = 51825
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netmaker[0].id
  description       = "wireguard client access"
}

resource "aws_security_group_rule" "netmaker_stun" {
  count             = var.enable_netmaker ? 1 : 0
  type              = "ingress"
  description       = "netmaker stun server access"
  from_port         = 3478
  to_port           = 3478
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netmaker[0].id

}

resource "aws_security_group_rule" "netmaker_proxy" {
  count             = var.enable_netmaker ? 1 : 0
  type              = "ingress"
  description       = "netmaker proxy access"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netmaker[0].id
}


resource "aws_security_group_rule" "netmaker_egress_all" {
  count             = var.enable_netmaker ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netmaker[0].id
}

resource "aws_instance" "netmaker" {
  count         = var.enable_netmaker ? 1 : 0
  ami           = var.bastion_ami
  instance_type = "t3.small"
  subnet_id     = element(module.vpc_netmaker[0].public_subnets, 0)
  user_data     = templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys })
  key_name      = local.cluster_domain

  vpc_security_group_ids = [aws_security_group.netmaker[0].id, module.vpc_netmaker[0].default_security_group_id]

  tags = merge({ Name = "${local.cluster_domain}-netmaker" }, local.common_tags)

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
