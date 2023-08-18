#############################
### VPC
#############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = local.cluster_domain
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs

  create_database_subnet_group = false

  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_nat_gateway            = true
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table = false

  tags = merge({}, local.common_tags)
  private_route_table_tags = {
    subnet-type = "private-cluster"
  }
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr
  networks = [
    for subnet in concat(local.private_subnets_list, local.public_subnets_list) : {
      name     = subnet
      new_bits = var.block_size
    }
  ]

}

resource "aws_security_group" "bastion" {
  name   = "${local.cluster_domain}-bastion"
  vpc_id = module.vpc.vpc_id
  tags   = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)
}

resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_wireguard" {
  type              = "ingress"
  from_port         = 51820
  to_port           = 51825
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "wireguard client access"
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  user_data                   = templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys })
  key_name                    = local.cluster_domain
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id, module.vpc.default_security_group_id]

  tags        = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)
  volume_tags = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.cluster_domain
  public_key = tls_private_key.ec2_ssh_key.public_key_openssh
}
