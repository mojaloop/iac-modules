module "ubuntu_focal_ami" {
  source  = "../ami-ubuntu"
  release = "20.04"
}

module "base_infra" {
  source                     = "../base-infra"
  cluster_name               = var.cluster_name
  domain                     = var.domain
  tags                       = var.tags
  vpc_cidr                   = var.vpc_cidr
  create_public_zone         = var.create_public_zone
  create_private_zone        = var.create_private_zone
  manage_parent_domain       = var.manage_parent_domain
  manage_parent_domain_ns    = var.manage_parent_domain_ns
  az_count                   = var.az_count
  route53_zone_force_destroy = var.dns_zone_force_destroy
  bastion_ami                = module.ubuntu_focal_ami.id
  create_haproxy_dns_record  = var.create_haproxy_dns_record
  block_size                 = var.block_size
}

module "post_config" {
  source              = "../post-config-k8s"
  name                = var.cluster_name
  domain              = var.domain
  tags                = var.tags
  private_zone_id     = module.base_infra.public_int_zone.id
  public_zone_id      = module.base_infra.public_zone.id
  create_ext_dns_user = var.create_ext_dns_user
  create_iam_user     = var.create_ci_iam_user
  iac_group_name      = var.iac_group_name
  backup_bucket_name  = "${var.domain}-${var.backup_bucket_name}"
  backup_enabled      = var.backup_enabled
}

module "k6s_test_harness" {
  count                       = var.enable_k6s_test_harness ? 1 : 0
  source                      = "../k6s-test-harness"
  cluster_name                = var.cluster_name
  domain                      = var.domain
  tags                        = var.tags
  vpc_cidr                    = var.vpc_cidr
  vpc_id                      = module.base_infra.vpc_id
  ami_id                      = module.ubuntu_focal_ami.id
  docker_server_instance_type = var.k6s_docker_server_instance_type
  subnet_id                   = module.base_infra.private_subnets[0]
  key_pair_name               = module.base_infra.key_pair_name
  public_zone_id              = module.base_infra.public_zone.id
  test_harness_hostname       = var.k6s_docker_server_fqdn
}

#############################
### Create Nodes
#############################
resource "aws_launch_template" "node" {
  for_each      = var.node_pools
  name_prefix   = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}"
  image_id      = module.ubuntu_focal_ami.id
  instance_type = each.value.instance_type
  user_data     = data.template_cloudinit_config.generic.rendered
  key_name      = module.base_infra.key_pair_name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted             = true
      volume_type           = "gp2"
      volume_size           = each.value.storage_gbs
      delete_on_termination = try(each.value.storage_delete_on_term, true)
    }
  }
  dynamic "block_device_mappings" {
    for_each = try(each.value.extra_vol, false) ? [each.value.extra_vol_name] : []

    content {
      device_name = each.value.extra_vol_name

      ebs {
        delete_on_termination = try(each.value.extra_vol_delete_on_term, true)
        encrypted             = true
        volume_size           = each.value.extra_vol_gbs
        volume_type           = "gp2"
      }
    }
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = each.value.master ? local.master_security_groups : local.agent_security_groups
  }


  tags = merge(
    { Name = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}" },
    local.common_tags
  )


  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { Name = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { Name = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}" },
      local.common_tags
    )
  }
  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      { Name = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}" },
      local.common_tags
    )
  }
  lifecycle {
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_autoscaling_group" "node" {
  for_each            = var.node_pools
  name_prefix         = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}"
  desired_capacity    = each.value.node_count
  max_size            = each.value.node_count
  min_size            = each.value.node_count
  vpc_zone_identifier = module.base_infra.private_subnets

  # Join the master to the internal load balancer for the kube api on 6443
  target_group_arns = each.value.master ? local.master_target_groups : local.agent_target_groups

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${local.name}-${each.key}-${each.value.master ? "master" : "agent"}"
    propagate_at_launch = false
  }
  tag {
    key                 = "Cluster"
    value               = var.cluster_name
    propagate_at_launch = true
  }
  tag {
    key                 = "Domain"
    value               = local.base_domain
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s-role"
    value               = each.value.master ? "master" : "agent"
    propagate_at_launch = true
  }
  tag {
    key                 = "nodepool-name"
    value               = each.key
    propagate_at_launch = true
  }
}


data "aws_instances" "node" {
  for_each      = var.node_pools
  instance_tags = merge({ nodepool-name = each.key, k8s-role = each.value.master ? "master" : "agent" }, local.identifying_tags)
  depends_on    = [aws_autoscaling_group.node]
}

data "template_cloudinit_config" "generic" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/cloud-config-base.yaml", { ssh_keys = local.ssh_keys })
  }
}

locals {
  base_security_groups    = [aws_security_group.self.id, module.base_infra.default_security_group_id]
  traffic_security_groups = [aws_security_group.ingress.id]
  kubeapi_target_groups = [
    aws_lb_target_group.internal_kubeapi.arn
  ]
  traffic_target_groups = [
    aws_lb_target_group.external_http.arn,
    aws_lb_target_group.external_https.arn,
    aws_lb_target_group.internal_http.arn,
    aws_lb_target_group.internal_https.arn,
    aws_lb_target_group.wireguard.arn
  ]
  master_target_groups   = var.master_node_supports_traffic ? concat(local.kubeapi_target_groups, local.traffic_target_groups) : local.kubeapi_target_groups
  agent_target_groups    = local.traffic_target_groups
  master_security_groups = var.master_node_supports_traffic ? concat(local.base_security_groups, local.traffic_security_groups) : local.base_security_groups
  agent_security_groups  = concat(local.base_security_groups, local.traffic_security_groups)
}
