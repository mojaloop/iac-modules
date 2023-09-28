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

  cluster_name                    = local.eks_name
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
      name         = "${local.eks_name}-agent"
      ami_id       = module.ubuntu_focal_ami.id
      public_ip    = false
      max_size     = var.agent_node_count
      desired_size = var.agent_node_count

      use_mixed_instances_policy      = false
      target_group_arns               = local.agent_target_groups
      key_name                        = module.base_infra.key_pair_name
      launch_template_name            = "${local.eks_name}-agent"
      launch_template_use_name_prefix = false
      iam_role_name                   = "${local.eks_name}-agent"
      iam_role_use_name_prefix        = false
      pre_bootstrap_user_data         = data.template_cloudinit_config.agent.rendered
      block_device_mappings = {
        device_name = "/dev/sda1"

        ebs = {
          encrypted   = true
          volume_type = "gp2"
          volume_size = var.agent_volume_size
        }
      }

      network_interfaces = [
        {
          delete_on_termination = true
          security_groups       = local.agent_security_groups
        }
      ]

      tags = merge(
        { Name = "${local.eks_name}-agent" },
        local.common_tags
      )

      tag_specifications = ["instance", "volume", "network-interface"]
    }

  }
  tags = var.tags
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_kubeconfig_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        module.eks.cluster_iam_role_arn
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}



resource "aws_iam_policy" "eks_kubeconfig_assume_role" {
  name   = "${local.eks_name}-eks-kubeconfig-assume-role"
  policy = data.aws_iam_policy_document.eks_kubeconfig_assume_role.json
}

resource "aws_iam_user_policy_attachment" "eks_kubeconfig_assume_role" {
  user       = split("/", data.aws_caller_identity.current.user_id)[1]
  policy_arn = aws_iam_policy.eks_kubeconfig_assume_role.arn
}

data "aws_region" "current" {}

data "utils_aws_eks_update_kubeconfig" "kubeconfig" {
  role_arn     = module.eks.cluster_iam_role_arn
  cluster_name = module.eks.cluster_name
  region       = data.aws_region.current.name
  kubeconfig   = "${path.module}/kubeconfig"
}

data "local_file" "kubeconfig" {
  filename = data.utils_aws_eks_update_kubeconfig.kubeconfig.kubeconfig
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


locals {
  eks_name                = substr(replace(local.base_domain, ".", "-"), 0, 16)
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
