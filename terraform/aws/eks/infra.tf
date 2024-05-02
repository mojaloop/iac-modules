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
  block_size                 = var.block_size
  route53_zone_force_destroy = var.dns_zone_force_destroy
  bastion_ami                = module.ubuntu_focal_ami.id
  create_haproxy_dns_record  = true
}

module "post_config" {
  source          = "../post-config-k8s"
  name            = var.cluster_name
  domain          = var.domain
  tags            = var.tags
  private_zone_id = module.base_infra.private_zone.id
  public_zone_id  = module.base_infra.public_zone.id
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
  source      = "terraform-aws-modules/eks/aws"
  version     = "~> 19.21"
  enable_irsa = true

  cluster_name                    = local.eks_name
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  vpc_id     = module.base_infra.vpc_id
  subnet_ids = module.base_infra.private_subnets
  cluster_addons = {
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      #addon_version            = "v1.18.0-eksbuild.1" #https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-add-on-self-managed-update
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  cluster_security_group_additional_rules = {

    ingress_https_bastion = {
      description              = "Access EKS from Bastion instance."
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = module.base_infra.bastion_security_group_id
    }
  }
  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
  }
  self_managed_node_groups = local.self_managed_node_groups
  tags                     = var.tags
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
  node_labels = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => {
      extra_args = [for key, label in node_pool.node_labels : "${key}=${label}"]
    }
  }
  node_taints = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => {
      extra_args = [for key, taint in node_pool.node_taints : "${taint}"]
    }
  }

  self_managed_node_groups = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => {
      name                            = "${local.eks_name}-${node_pool_key}"
      ami_id                          = data.aws_ami.eks_default.id
      instance_type                   = node_pool.instance_type
      public_ip                       = false
      max_size                        = node_pool.node_count
      desired_size                    = node_pool.node_count
      use_mixed_instances_policy      = false
      target_group_arns               = local.agent_target_groups
      key_name                        = module.base_infra.key_pair_name
      launch_template_name            = "${local.eks_name}-${node_pool_key}"
      launch_template_use_name_prefix = false
      iam_role_name                   = "${local.eks_name}-${node_pool_key}"
      iam_role_use_name_prefix        = false
      iam_role_attach_cni_policy      = true
      bootstrap_extra_args            = "--use-max-pods false --kubelet-extra-args '--max-pods=110 --node-labels=${join(",", local.node_labels[node_pool_key].extra_args)} --register-with-taints=${join(",", local.node_taints[node_pool_key].extra_args)}'"
      post_bootstrap_user_data        = <<-EOT
        yum install iscsi-initiator-utils -y && sudo systemctl enable iscsid && sudo systemctl start iscsid
      EOT
      ebs_optimized                   = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = node_pool.storage_gbs
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }

      }

      network_interfaces = [
        {
          delete_on_termination = true
          security_groups       = local.agent_security_groups
        }
      ]

      tags = merge(
        { Name = "${local.eks_name}-${node_pool_key}" },
        local.common_tags
      )

      tag_specifications = ["instance", "volume", "network-interface"]
    }
  }
}

module "vpc_cni_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "~> 5.39"
  role_name             = "AmazonEKSVPCCNIRole"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-v*"]
  }
}

data "aws_ami" "eks_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}
#-register-with-taints=spotInstance=true:PreferNoSchedule add for taints in bootstrap_extra_args
