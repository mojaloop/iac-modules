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
  single_nat_gateway            = true
  one_nat_gateway_per_az        = false
  reuse_nat_ips                 = false
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  map_public_ip_on_launch       = true

  tags = merge({}, local.common_tags)
  private_route_table_tags = {
    subnet-type = "private-cluster"
  }
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr
  networks = [
    for subnet in local.subnet_list : {
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

# resource "aws_instance" "bastion" {
#   ami                         = var.bastion_ami
#   instance_type               = "t2.micro"
#   subnet_id                   = element(module.vpc.public_subnets, 0)
#   user_data                   = templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys })
#   key_name                    = local.cluster_domain
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.bastion.id, module.vpc.default_security_group_id]

#   tags        = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)
#   volume_tags = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)

#   lifecycle {
#     ignore_changes = [
#       ami
#     ]
#   }
# }

resource "aws_launch_template" "bastion" {
  name_prefix   = var.bastion_asg_config.name_prefix
  image_id      = module.ubuntu_focal_ami.id
  instance_type = var.bastion_asg_config.instance_type
  user_data     = data.template_cloudinit_config.generic.rendered
  key_name      = module.base_infra.key_pair_name

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion.id, module.vpc.default_security_group_id]
    #subnet_id                   = element(module.vpc.public_subnets, 0)
  }

  #user_data = base64encode(templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys }))

  tag_specifications {
    resource_type = "instance"
    tags = merge({ 
      Name = "${local.cluster_domain}-bastion" 
    }, local.common_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({ 
      Name = "${local.cluster_domain}-bastion" 
    }, local.common_tags)
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge({ 
      Name = "${local.cluster_domain}-bastion" 
    }, local.common_tags)
  }

  lifecycle {
    ignore_changes = [
      image_id  # Equivalent to ignoring changes to 'ami' in aws_instance
    ]
  }
}


#  Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "bastion_asg" {
  name                = var.bastion_asg_config.name
  min_size            = var.bastion_asg_config.min_size
  desired_capacity    = var.bastion_asg_config.desired_capacity
  max_size            = var.bastion_asg_config.max_size

  vpc_zone_identifier = module.base_infra.public_subnets

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300  # Allow 5 minutes for instance to become healthy

  tag {
    key                 = "Name"
    value               = "${local.cluster_domain}-bastion"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
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

