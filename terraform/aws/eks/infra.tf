module "ubuntu_focal_ami" {
  source  = "../ami-ubuntu"
  release = "20.04"
}

module "ubuntu_jammy_ami" {
  source  = "../ami-ubuntu"
  release = "22.04"
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
  bastion_ami                = module.ubuntu_jammy_ami.id
  create_haproxy_dns_record  = var.create_haproxy_dns_record
  block_size                 = var.block_size
  single_nat_gateway         = var.single_nat_gateway
  single_zone_bastion_asg    = var.single_zone_bastion_asg
  bastion_asg_config = {
    name             = "bastion"
    desired_capacity = var.bastion_instance_number
    max_size         = var.bastion_instance_number
    min_size         = var.bastion_instance_number
    instance_type    = var.bastion_instance_size
  }
}

module "post_config" {
  source                      = "../post-config-k8s"
  name                        = var.cluster_name
  domain                      = var.domain
  tags                        = var.tags
  private_zone_id             = module.base_infra.public_int_zone.id
  public_zone_id              = module.base_infra.public_zone.id
  create_ext_dns_user         = var.create_ext_dns_user
  create_ext_dns_role         = var.create_ext_dns_role
  create_csi_role             = var.create_csi_role
  create_iam_user             = var.create_ci_iam_user
  iac_group_name              = var.iac_group_name
  backup_bucket_name          = "${var.domain}-${var.backup_bucket_name}"
  backup_enabled              = var.backup_enabled
  backup_bucket_force_destroy = var.backup_bucket_force_destroy
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
  version     = "~> 20.37"
  enable_irsa = true

  cluster_name                    = local.eks_name
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  authentication_mode             = "API_AND_CONFIG_MAP"

  # Enable the default key policy (no need for kms_key_administrators or kms_key_owners)
  kms_key_enable_default_policy = true

  vpc_id                   = module.base_infra.vpc_id
  subnet_ids               = var.single_zone_az_nodegroup ? [module.base_infra.private_subnets[0]] : module.base_infra.private_subnets
  control_plane_subnet_ids = module.base_infra.private_subnets

  cluster_addons = {
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION           = "true"
          WARM_PREFIX_TARGET                 = "1"
          AWS_VPC_K8S_CNI_EXCLUDE_SNAT_CIDRS = "${var.netbird_ip_range},${var.cc_cidr_block}"
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
    update_launch_template_default_version = var.update_launch_template_default_version
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${local.eks_name}" : "owned",
    }
  }
  # Conditionally include OIDC configuration if var.enable_oidc is true
  cluster_identity_providers = var.eks_oidc_enabled ? {
    oidc = {
      identity_provider_config_name = var.identity_provider_config_name
      issuer_url                    = var.kubernetes_oidc_issuer
      client_id                     = var.kubernetes_oidc_client_id
      groups_claim                  = var.kubernetes_oidc_groups_claim
      #groups_prefix                = var.kubernetes_oidc_groups_prefix
      username_claim = var.kubernetes_oidc_username_claim
      #username_prefix              = var.kubernetes_oidc_username_prefix
    }
  } : {}

  self_managed_node_groups = local.self_managed_node_groups
  create_cloudwatch_log_group = var.enable_eks_controlplane_logging
  cluster_enabled_log_types   = var.enable_eks_controlplane_logging ? var.cluster_enabled_log_types : []
  tags                     = var.tags
}

# CI user eks
resource "aws_iam_role" "eks_access_role" {
  name = "${local.eks_name}-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = local.eks_user_arns
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge({ Name = "${local.eks_name}-eks-access-role" }, var.tags)
}

locals {
  eks_name = substr(replace(local.base_domain, ".", "-"), 0, 16)
  kubernetes_minor_version = tonumber(split(".", var.kubernetes_version)[1])
  eks_user_arns = distinct(compact([
    module.post_config.ci_user_arn,
    data.aws_caller_identity.current_user.arn
  ]))

  aws_auth_configmap_yaml = templatefile("${path.module}/templates/aws_auth_cm.tpl",
    {
      node_iam_role_arns = distinct(
        compact(
          concat(
            [for group in module.eks.eks_managed_node_groups : group.iam_role_arn if group.platform != "windows"],
            [for group in module.eks.self_managed_node_groups : group.iam_role_arn if group.platform != "windows"]
          )
        )
      ),
      iam_user_role_arns = [aws_iam_role.eks_access_role.arn]
    }
  )
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
  node_pool_os = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => try(lower(trimspace(node_pool.node_os)), "")
  }
  node_pool_ami_type = { for node_pool_key, node_os in local.node_pool_os :
    node_pool_key => node_os == "al2023" ? "AL2023_x86_64_STANDARD" : node_os == "al2" ? "AL2_x86_64" : null
  }
  # Keep the legacy AL2 node pools on the same fixed EKS AMI naming path they used before this migration work.
  legacy_al2_ami_version = "v20241225"
  recommended_ami_ssm_parameter = {
    AL2023_x86_64_STANDARD = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
  }
  node_pool_ami_ssm_parameter = { for node_pool_key, ami_type in local.node_pool_ami_type :
    node_pool_key => local.recommended_ami_ssm_parameter[ami_type]
    if ami_type == "AL2023_x86_64_STANDARD"
  }
  node_pool_al2_fixed_ami_name = { for node_pool_key, node_os in local.node_pool_os :
    node_pool_key => "amazon-eks-node-${var.kubernetes_version}-${local.legacy_al2_ami_version}"
    if node_os == "al2"
  }
  node_pool_create_access_entry = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => try(node_pool.create_access_entry, local.node_pool_os[node_pool_key] == "al2023")
  }
  invalid_node_os_pools = [
    for node_pool_key, node_os in local.node_pool_os : node_pool_key
    if !contains(["al2", "al2023"], node_os)
  ]
  unsupported_al2_node_pools = local.kubernetes_minor_version >= 33 ? [
    for node_pool_key, node_os in local.node_pool_os : node_pool_key
    if node_os == "al2"
  ] : []
  al2023_registry_mirror_enabled = var.enable_registry_mirror && length(var.container_registry_mirrors) > 0 && trimspace(var.registry_mirror_fqdn) != ""
  registry_mirror_basic_auth     = trimspace(var.docker_registry_username) != "" && trimspace(var.docker_registry_password) != "" ? base64encode("${var.docker_registry_username}:${var.docker_registry_password}") : ""
  al2_post_bootstrap_user_data = templatefile("${path.module}/templates/post-bootstrap-user-data.sh.tpl", {
    netbird_version            = var.netbird_version
    netbird_api_host           = var.netbird_api_host
    netbird_setup_key          = var.netbird_setup_key
    pod_network_cidr           = var.vpc_cidr
    container_registry_mirrors = join(" ", var.container_registry_mirrors)
    enable_registry_mirror     = var.enable_registry_mirror
    registry_mirror_fqdn       = var.registry_mirror_fqdn
    docker_registry_username   = var.docker_registry_username
    docker_registry_password   = var.docker_registry_password
  })

  self_managed_node_groups = { for node_pool_key, node_pool in var.node_pools :
    node_pool_key => {
      name                            = "${local.eks_name}-${node_pool_key}"
      ami_id                          = local.node_pool_os[node_pool_key] == "al2" ? data.aws_ami.eks_al2_fixed[node_pool_key].id : try(nonsensitive(data.aws_ssm_parameter.eks_recommended[node_pool_key].value), null)
      ami_type                        = local.node_pool_ami_type[node_pool_key]
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
      create_access_entry             = local.node_pool_create_access_entry[node_pool_key]
      vpc_security_group_ids = [
        module.eks.cluster_primary_security_group_id
      ]
      bootstrap_extra_args     = local.node_pool_os[node_pool_key] == "al2" ? "--use-max-pods false --kubelet-extra-args '--cluster-dns=${var.coredns_bind_address} --allowed-unsafe-sysctls=net.ipv4.ip_forward --max-pods=122 --node-labels=${join(",", local.node_labels[node_pool_key].extra_args)} --register-with-taints=${join(",", local.node_taints[node_pool_key].extra_args)}'" : ""
      pre_bootstrap_user_data  = ""
      post_bootstrap_user_data = local.node_pool_os[node_pool_key] == "al2" ? local.al2_post_bootstrap_user_data : ""
      cloudinit_pre_nodeadm = local.node_pool_os[node_pool_key] == "al2023" ? [
        {
          content_type = "application/node.eks.aws"
          content = templatefile("${path.module}/templates/nodeadm-user-data.yaml.tpl", {
            cluster_dns                = var.coredns_bind_address
            node_labels                = join(",", local.node_labels[node_pool_key].extra_args)
            node_taints                = join(",", local.node_taints[node_pool_key].extra_args)
            configure_containerd_hosts = local.al2023_registry_mirror_enabled
          })
        }
      ] : []
      cloudinit_post_nodeadm = local.node_pool_os[node_pool_key] == "al2023" && local.al2023_registry_mirror_enabled ? [
        {
          content_type = "text/x-shellscript"
          content = templatefile("${path.module}/templates/al2023-registry-mirror.sh.tpl", {
            container_registry_mirrors = var.container_registry_mirrors
            registry_mirror_fqdn       = var.registry_mirror_fqdn
            registry_mirror_basic_auth = local.registry_mirror_basic_auth
          })
        }
      ] : []
      ebs_optimized = true

      block_device_mappings = merge(
        {
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
        },
        # Check if extra_vols is defined and has volumes, then map each volume.
        try(length(node_pool.extra_vols) > 0, false) ? {
          for vol in node_pool.extra_vols : vol.name => {
            device_name = vol.name
            ebs = {
              volume_size           = vol.size
              volume_type           = "gp3"
              iops                  = 3000
              throughput            = 150
              encrypted             = true
              delete_on_termination = try(vol.extra_vol_delete_on_term, true)
            }
          }
        } : {}
      )

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

data "aws_caller_identity" "current_user" {}

resource "null_resource" "validate_node_pool_configuration" {
  lifecycle {
    precondition {
      condition     = length(local.invalid_node_os_pools) == 0
      error_message = "Each node pool must set node_os to one of: al2, al2023. Invalid node pools: ${join(", ", local.invalid_node_os_pools)}"
    }

    precondition {
      condition     = length(local.unsupported_al2_node_pools) == 0
      error_message = "Amazon Linux 2 node pools are not supported for Kubernetes 1.33 and later. Invalid node pools: ${join(", ", local.unsupported_al2_node_pools)}"
    }
  }
}

data "aws_ami" "eks_al2_fixed" {
  for_each = local.node_pool_al2_fixed_ami_name

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [each.value]
  }
}

data "aws_ssm_parameter" "eks_recommended" {
  for_each = {
    for node_pool_key, ssm_parameter in local.node_pool_ami_ssm_parameter : node_pool_key => ssm_parameter
    if local.node_pool_os[node_pool_key] == "al2023"
  }

  name = each.value
}

data "aws_ami" "eks_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

}
#-register-with-taints=spotInstance=true:PreferNoSchedule add for taints in bootstrap_extra_args
