module "ubuntu_focal_ami" {
  source  = "../ami-ubuntu"
  release = "20.04"
}

module "base_infra" {
  source = "../base-infra"

  cluster_name               = var.cluster_name
  domain                     = var.domain
  tags                       = var.tags
  vpc_cidr                   = var.vpc_cidr
  create_public_zone         = var.create_public_zone
  create_private_zone        = var.create_private_zone
  az_count                   = var.az_count
  route53_zone_force_destroy = var.route53_zone_force_destroy
  bastion_ami                = module.ubuntu_focal_ami.id
  netmaker_ami               = module.ubuntu_focal_ami.id
  enable_netmaker            = var.enable_netmaker
}

module "post_config" {
  source                      = "../post-config-control-center"
  name                        = local.name
  domain                      = local.base_domain
  public_zone_id              = module.base_infra.public_zone.zone_id
  private_zone_id             = module.base_infra.private_zone.zone_id
  tags                        = var.tags
  days_retain_gitlab_snapshot = var.days_retain_gitlab_snapshot
}

resource "aws_instance" "gitlab_server" {
  ami                         = module.ubuntu_focal_ami.id
  instance_type               = var.gitlab_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.gitlab_server.id]
  iam_instance_profile        = aws_iam_instance_profile.gitlab.name
  key_name                    = module.base_infra.key_pair_name
  subnet_id                   = module.base_infra.public_subnets[0]
  tags                        = merge({ Name = "${local.name}-gitlab-server" }, local.common_tags)

  volume_tags                 = merge({ Name = "${local.name}-gitlab-server" }, local.common_tags)
  root_block_device {
    delete_on_termination = var.delete_storage_on_term
    volume_type           = "gp2"
    volume_size           = var.gitlab_server_root_vol_size
  }

  ebs_block_device {
    delete_on_termination = var.delete_storage_on_term
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = var.gitlab_server_extra_vol_size
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_instance" "docker_server" {
  ami                         = module.ubuntu_focal_ami.id
  instance_type               = var.docker_server_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.docker_server.id]
  key_name                    = module.base_infra.key_pair_name
  subnet_id                   = module.base_infra.private_subnets[0]
  tags                        = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
  volume_tags                 = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
  root_block_device {
    delete_on_termination = var.delete_storage_on_term
    volume_type           = "gp2"
    volume_size           = var.docker_server_root_vol_size
  }
  ebs_block_device {
    delete_on_termination = var.delete_storage_on_term
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = var.docker_server_extra_vol_size
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
