terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/gitops/cc-cluster-config?ref=${get_env("iac_terraform_modules_tag")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    master_hosts                     = {}
    bastion_hosts                    = {}
    public_subdomain                 = "cc.example.com"
    private_subdomain                = "int.cc.example.com"
    target_group_internal_https_port = 31443
    target_group_internal_http_port  = 31080
    target_group_internal_health_port = 31081
    target_group_external_https_port = 32443
    target_group_external_http_port  = 32080
    target_group_external_health_port = 32081
    target_group_vpn_port            = 30333
    target_group_vpn_health_port     = 31822
    internal_load_balancer_dns       = "internal.lb"
    external_load_balancer_dns       = "external.lb"
    external_dns_cloud_role          = "arn:aws:iam::123456789:role/ext-dns"
    ext_dns_cloud_policy             = "arn:aws:iam::123456789:policy/cert-manager"
    secrets_key_map = {
      iac_user_cred_id_key     = "testkey1"
      iac_user_cred_secret_key = "testkey2"
    }
    secrets_var_map = {
      testkey1 = "testval1"
      testkey2 = "testval2"
    }
    private_subnets       = ["subnet-1", "subnet-2"]
    vpc_id                = "vpc-123"
    availability_zones    = ["us-east-1a", "us-east-1b"]
    object_storage_cloud_role  = "arn:aws:iam::123456789:role/object-storage"
    object_storage_bucket_name = "velero-bucket"
    private_dns_zone_id        = "Z123456"
    external_load_balancer_private_ip = "10.0.0.1"
    all_hosts_var_maps = {
      ssh_public_key = "ssh-rsa AAAA..."
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "deep"
}

inputs = {
  argocd_override = yamldecode(templatefile("../ansible-k8s-deploy/templates/argoapps.yaml.tpl", merge(
    (local.K8S_CLUSTER_TYPE == "microk8s") ? {} : {}, {
    nexus_ansible_collection_tag      = local.env_vars.ansible_collection_tag
    netbird_ansible_collection_tag    = local.env_vars.ansible_collection_tag
    harbor_ansible_collection_tag     = local.env_vars.ansible_collection_tag
    dns_public_subdomain              = dependency.k8s_deploy.outputs.public_subdomain
    dns_private_subdomain             = dependency.k8s_deploy.outputs.private_subdomain
    internal_ingress_https_port       = dependency.k8s_deploy.outputs.target_group_internal_https_port
    internal_ingress_http_port        = dependency.k8s_deploy.outputs.target_group_internal_http_port
    internal_ingress_health_port      = dependency.k8s_deploy.outputs.target_group_internal_health_port
    external_ingress_https_port       = dependency.k8s_deploy.outputs.target_group_external_https_port
    external_ingress_http_port        = dependency.k8s_deploy.outputs.target_group_external_http_port
    external_ingress_health_port      = dependency.k8s_deploy.outputs.target_group_external_health_port
    internal_load_balancer_dns        = dependency.k8s_deploy.outputs.internal_load_balancer_dns
    external_load_balancer_dns        = dependency.k8s_deploy.outputs.external_load_balancer_dns
    wireguard_ingress_port            = dependency.k8s_deploy.outputs.target_group_vpn_port
    wireguard_health_port             = dependency.k8s_deploy.outputs.target_group_vpn_health_port
    external_dns_cloud_role           = dependency.k8s_deploy.outputs.external_dns_cloud_role
    cert_manager_cloud_policy         = dependency.k8s_deploy.outputs.ext_dns_cloud_policy
    cloud_platform_api_client_id      = dependency.k8s_deploy.outputs.secrets_var_map[dependency.k8s_deploy.outputs.secrets_key_map.iac_user_cred_id_key]
    cloud_platform_api_client_secret  = dependency.k8s_deploy.outputs.secrets_var_map[dependency.k8s_deploy.outputs.secrets_key_map.iac_user_cred_secret_key]
    environment_list                  = local.environment_list.environments
    rdbms_subnet_list                 = dependency.k8s_deploy.outputs.private_subnets
    rdbms_vpc_id                      = dependency.k8s_deploy.outputs.vpc_id
    rdbms_azs                         = dependency.k8s_deploy.outputs.availability_zones
    vpc_cidr                          = get_env("vpc_cidr")
    object_storage_cloud_role         = dependency.k8s_deploy.outputs.object_storage_cloud_role
    object_storage_bucket_name        = dependency.k8s_deploy.outputs.object_storage_bucket_name
    rook_csi_kubelet_dir_path         = local.K8S_CLUSTER_TYPE == "microk8s" ? "/var/snap/microk8s/common/var/lib/kubelet" : "/var/lib/kubelet"
    eks_name                          = local.eks_name
    cluster_domain                    = local.cluster_domain
    capi_cluster_proxmox_host_sshkey  = try(dependency.k8s_deploy.outputs.all_hosts_var_maps.ssh_public_key, "")
    cloud_platform                    = get_env("cloud_platform")
    object_storage_provider           = get_env("object_storage_provider")
    private_dns_zone_id               = dependency.k8s_deploy.outputs.private_dns_zone_id
    external_load_balancer_private_ip = dependency.k8s_deploy.outputs.external_load_balancer_private_ip
  }, local.common_vars, local.env_vars))).argocd_override

  cluster_name               = get_env("cluster_name")
  cloud_provider             = get_env("cloud_platform")
  gitrepo_host_fqdn          = local.gitlab_fqdn
  gitrepo_owner              = local.GITLAB_CURRENT_GROUP_NAME
  gitrepo_repo               = "iac-modules"
  ansible_gitrepo            = "iac-ansible-collection-roles"
  ansible_collection_path    = "mojaloop/iac"
  root_app_gitrepo_path      = "gitops/argo-apps/base"
  argocd_namespace           = "argocd"
  dns_public_subdomain       = dependency.k8s_deploy.outputs.public_subdomain
  dns_private_subdomain      = dependency.k8s_deploy.outputs.private_subdomain
  output_dir                 = local.GITOPS_BUILD_OUTPUT_DIR
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  common_vars      = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}"))
  environment_list = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/environment.yaml")}"))
  K8S_CLUSTER_TYPE = get_env("k8s_cluster_type")
  CLUSTER_NAME     = get_env("cluster_name")
  eks_name         = substr("${replace(get_env("cluster_name"), "-", "")}-${replace(get_env("domain"), ".", "-")}", 0, 16)
  cluster_domain   = "${get_env("cluster_name")}.${get_env("domain")}"
  gitlab_fqdn      = "gitlab.${get_env("cluster_name")}.${get_env("domain")}"
  GITLAB_CURRENT_GROUP_NAME = get_env("GITLAB_CURRENT_GROUP_NAME", "iac")
  GITOPS_BUILD_OUTPUT_DIR   = get_env("GITOPS_BUILD_OUTPUT_DIR", "${get_terragrunt_dir()}/output")
}

include "root" {
  path = find_in_parent_folders()
}
