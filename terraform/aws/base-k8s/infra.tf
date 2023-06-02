module "ubuntu_focal_ami" {
  source  = "../ami-ubuntu"
  release = "20.04"
}

module "base_infra" {
  source  = "../base-infra"
  cluster_name = var.cluster_name
  domain = var.domain
  tags = var.tags
  vpc_cidr = var.vpc_cidr
  create_public_zone = var.create_public_zone
  create_private_zone = var.create_private_zone
  manage_parent_domain = var.manage_parent_domain
  manage_parent_domain_ns = var.manage_parent_domain_ns
  az_count = var.az_count
  route53_zone_force_destroy = var.route53_zone_force_destroy
  bastion_ami = module.ubuntu_focal_ami.id
}

module "post_config" {
  source  = "../post-config-k8s"
  name = var.cluster_name
  domain = var.domain
  tags = var.tags
  private_zone_id = module.base_infra.private_zone.id
  public_zone_id = module.base_infra.public_zone.id
  current_gitlab_project_id = var.current_gitlab_project_id
  longhorn_backup_s3_destroy = var.longhorn_backup_s3_destroy
}

#############################
### Create Nodes
#############################
resource "aws_launch_template" "master" {
  name_prefix   = "${local.name}-master"
  image_id      = module.ubuntu_focal_ami.id
  instance_type = var.master_instance_type
  user_data     = data.template_cloudinit_config.master.rendered
  key_name      = module.base_infra.key_pair_name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = var.master_volume_size
    }
  }

  network_interfaces {
    delete_on_termination = true
    security_groups       = local.master_security_groups
  }


  tags = merge(
    { Name = "${local.name}-master" },
    local.common_tags
  )


  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { Name = "${local.name}-master" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { Name = "${local.name}-master" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      { Name = "${local.name}-master" },
      local.common_tags
    )
  }
  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_launch_template" "agent" {
  name_prefix   = "${local.name}-agent"
  image_id      = module.ubuntu_focal_ami.id
  instance_type = var.agent_instance_type
  user_data     = data.template_cloudinit_config.agent.rendered
  key_name      = module.base_infra.key_pair_name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = var.agent_volume_size
    }
  }

  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.ingress.id, aws_security_group.self.id, module.base_infra.default_security_group_id]
  }

  tags = merge(
    { Name = "${local.name}-agent" },
    local.common_tags
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { Name = "${local.name}-agent" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { Name = "${local.name}-agent" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      { Name = "${local.name}-agent" },
      local.common_tags
    )
  }
  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_autoscaling_group" "master" {
  name_prefix         = "${local.name}-master"
  desired_capacity    = var.master_node_count
  max_size            = var.master_node_count
  min_size            = var.master_node_count
  vpc_zone_identifier = module.base_infra.private_subnets

  # Join the master to the internal load balancer for the kube api on 6443
  target_group_arns = [
    aws_lb_target_group.internal_kubeapi.arn
  ]

  launch_template {
    id      = aws_launch_template.master.id
    version = "$Latest"
  }
  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${local.name}-master"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "Cluster"
        "value"               = var.cluster_name
        "propagate_at_launch" = false
      },
      {
        "key"                 = "Domain"
        "value"               = local.base_domain
        "propagate_at_launch" = false
      }
    ]
  )
}

resource "aws_autoscaling_group" "agent" {
  name_prefix         = "${local.name}-agent"
  desired_capacity    = var.agent_node_count
  max_size            = var.agent_node_count
  min_size            = var.agent_node_count
  vpc_zone_identifier = module.base_infra.private_subnets

  target_group_arns = [
    aws_lb_target_group.external_http.arn,
    aws_lb_target_group.external_https.arn,
    aws_lb_target_group.internal_http.arn,
    aws_lb_target_group.internal_https.arn,
    aws_lb_target_group.wireguard.arn
  ]

  launch_template {
    id      = aws_launch_template.agent.id
    version = "$Latest"
  }
  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${local.name}-agent"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "Cluster"
        "value"               = var.cluster_name
        "propagate_at_launch" = false
      },
      {
        "key"                 = "Domain"
        "value"               = local.base_domain
        "propagate_at_launch" = false
      }
    ]
  )

}

data "aws_instances" "master" {
  instance_tags = merge({ Name = "${local.name}-master" }, local.identifying_tags)
  depends_on    = [aws_autoscaling_group.master]
}

data "aws_instances" "agent" {
  count         = var.agent_node_count > 0 ? 1 : 0
  instance_tags = merge({ Name = "${local.name}-agent" }, local.identifying_tags)
  depends_on    = [aws_autoscaling_group.agent]
}

data "template_cloudinit_config" "agent" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/cloud-config-base.yaml", { ssh_keys = local.ssh_keys })
  }
}

data "template_cloudinit_config" "master" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/cloud-config-base.yaml", { ssh_keys = local.ssh_keys })
  }
}