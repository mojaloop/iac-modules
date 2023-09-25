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
  create_haproxy_dns_record  = true
}

module "post_config" {
  source                     = "../post-config-k8s"
  name                       = var.cluster_name
  domain                     = var.domain
  tags                       = var.tags
  private_zone_id            = module.base_infra.private_zone.id
  public_zone_id             = module.base_infra.public_zone.id
  longhorn_backup_s3_destroy = var.longhorn_backup_object_store_destroy
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

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.base_domain
  cluster_version                 = "1.24"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false


  vpc_id     = module.base_infra.vpc_id
  subnet_ids = module.base_infra.private_subnets

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = var.agent_instance_type
    update_launch_template_default_version = true
  }

  self_managed_node_groups = {
    agent = {
      name = "${var.cluster_name}-agent-node-group"
      ami_id =  module.ubuntu_focal_ami.id
      public_ip    = false
      max_size     = var.agent_node_count
      desired_size = var.agent_node_count

      use_mixed_instances_policy = false
      target_group_arns = local.agent_target_groups
      key_name      = module.base_infra.key_pair_name
      launch_template_name = "${local.base_domain}-agent"
      launch_template_use_name_prefix = true
      pre_bootstrap_user_data = data.template_cloudinit_config.agent.rendered
      block_device_mappings = {
        device_name = "/dev/sda1"

        ebs = {
          encrypted   = true
          volume_type = "gp2"
          volume_size = var.agent_volume_size
        }
      }

      network_interfaces = {
        delete_on_termination = true
        security_groups       = local.agent_security_groups
      }

      tags = merge(
        { Name = "${local.base_domain}-agent" },
        local.common_tags
      )

      tag_specifications = {
        resource_type = "instance"

        tags = merge(
          { Name = "${local.base_domain}-agent" },
          local.common_tags
        )
      }
      tag_specifications = {
        resource_type = "volume"

        tags = merge(
          { Name = "${local.base_domain}-agent" },
          local.common_tags
        )
      }
      tag_specifications = {
        resource_type = "network-interface"

        tags = merge(
          { Name = "${local.base_domain}-agent" },
          local.common_tags
        )
      }
    }

  }
  tags = var.tags
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

module "eks_kubeconfig" {
  source       = "hyperbadger/eks-kubeconfig/aws"
  version      = "2.0.0"
  cluster_name = module.eks.cluster_name
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
