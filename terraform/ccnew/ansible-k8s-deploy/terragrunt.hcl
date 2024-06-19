terraform {
  source = "git::https://github.com/mojaloop/iac-modules.git//terraform/ansible/cc-k8s-deploy?ref=${get_env("iac_terraform_modules_tag")}"
}

dependency "k8s_deploy" {
  config_path = "../k8s-deploy"
  mock_outputs = {
    master_hosts                = {}
    agent_hosts                 = {}
    bastion_hosts               = {}
    bastion_hosts_var_maps      = {}
    agent_hosts_var_maps        = {}
    master_hosts_var_maps       = {}
    all_hosts_var_maps          = {}
    master_hosts_yaml_maps      = {}
    agent_hosts_yaml_maps       = {}
    bastion_hosts_yaml_maps     = {}
    test_harness_hosts          = {}
    test_harness_hosts_var_maps = {}
    bastion_ssh_key             = "key"
    bastion_os_username         = "null"
    bastion_public_ip           = "null"
    haproxy_server_fqdn         = "null"
    private_subdomain           = "null"
    public_subdomain            = "null"
    target_group_internal_https_port = 0
    target_group_internal_http_port = 0
    target_group_internal_health_port = 0
    target_group_external_https_port = 0
    target_group_external_http_port = 0
    target_group_external_health_port = 0
    target_group_vpn_port = 0
    internal_load_balancer_dns = "null"
    external_load_balancer_dns = "null"
    secrets_key_map = {
      external_dns_cred_id_key = "testkey1"
      external_dns_cred_secret_key = "testkey2"
    }
    secrets_var_map = {
      testkey1 = "testval1"
      testkey2 = "testval1"
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  master_hosts  = dependency.k8s_deploy.outputs.master_hosts
  agent_hosts   = dependency.k8s_deploy.outputs.agent_hosts
  bastion_hosts = dependency.k8s_deploy.outputs.bastion_hosts
  bastion_hosts_var_maps = merge(dependency.k8s_deploy.outputs.bastion_hosts_var_maps, local.bastion_hosts_var_maps, {
    dns_cloud_api_client_id      = dependency.k8s_deploy.outputs.secrets_var_map[dependency.k8s_deploy.outputs.secrets_key_map.external_dns_cred_id_key]
    dns_cloud_api_client_secret  = dependency.k8s_deploy.outputs.secrets_var_map[dependency.k8s_deploy.outputs.secrets_key_map.external_dns_cred_secret_key]
    dns_public_subdomain         = dependency.k8s_deploy.outputs.public_subdomain
    dns_private_subdomain        = dependency.k8s_deploy.outputs.private_subdomain
    internal_ingress_https_port  = dependency.k8s_deploy.outputs.target_group_internal_https_port
    internal_ingress_http_port   = dependency.k8s_deploy.outputs.target_group_internal_http_port
    internal_ingress_health_port = dependency.k8s_deploy.outputs.target_group_internal_health_port
    external_ingress_https_port  = dependency.k8s_deploy.outputs.target_group_external_https_port
    external_ingress_http_port   = dependency.k8s_deploy.outputs.target_group_external_http_port
    external_ingress_health_port = dependency.k8s_deploy.outputs.target_group_external_health_port
    internal_load_balancer_dns   = dependency.k8s_deploy.outputs.internal_load_balancer_dns
    external_load_balancer_dns   = dependency.k8s_deploy.outputs.external_load_balancer_dns
    stunner_nodeport_port        = dependency.k8s_deploy.outputs.target_group_vpn_port
  })
  agent_hosts_var_maps          = dependency.k8s_deploy.outputs.agent_hosts_var_maps
  master_hosts_var_maps         = dependency.k8s_deploy.outputs.master_hosts_var_maps
  all_hosts_var_maps            = merge(dependency.k8s_deploy.outputs.all_hosts_var_maps,
  {
    registry_mirror_fqdn        = dependency.k8s_deploy.outputs.haproxy_server_fqdn
  }, (local.K8S_CLUSTER_TYPE == "microk8s") ? {
    microk8s_dns_resolvers = try(dependency.k8s_deploy.outputs.all_hosts_var_maps.dns_resolver_ip, "")
    microk8s_version       = try(local.common_vars.microk8s_version, "1.29/stable")
    microk8s_dev_skip      = try(local.env_vars.microk8s_dev_skip, false)
  } : {})
  bastion_hosts_yaml_maps       = dependency.k8s_deploy.outputs.bastion_hosts_yaml_maps
  master_hosts_yaml_maps        = dependency.k8s_deploy.outputs.master_hosts_yaml_maps
  agent_hosts_yaml_maps         = dependency.k8s_deploy.outputs.agent_hosts_yaml_maps
  ansible_bastion_key           = dependency.k8s_deploy.outputs.bastion_ssh_key
  ansible_bastion_os_username   = dependency.k8s_deploy.outputs.bastion_os_username
  ansible_bastion_public_ip     = dependency.k8s_deploy.outputs.bastion_public_ip
  ansible_collection_tag        = local.env_vars.ansible_collection_tag
  ansible_base_output_dir       = local.ANSIBLE_BASE_OUTPUT_DIR
  ansible_playbook_name         = "cc${local.K8S_CLUSTER_TYPE}_cluster_deploy"
  ansible_destroy_playbook_name = "cc${local.K8S_CLUSTER_TYPE}_cluster_destroy"
  master_node_supports_traffic = (local.total_agent_count == 0) ? true : false
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/cluster-config.yaml")}"))
  common_vars = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/common-vars.yaml")}"))
  ANSIBLE_BASE_OUTPUT_DIR          = get_env("ANSIBLE_BASE_OUTPUT_DIR")
  K8S_CLUSTER_TYPE                 = get_env("k8s_cluster_type")
  CLUSTER_NAME                     = get_env("cluster_name")

  total_agent_count  = try(sum([for node in local.env_vars.nodes : node.node_count if !node.master]), 0)
  total_master_count = try(sum([for node in local.env_vars.nodes : node.node_count if node.master]), 0)

  bastion_hosts_var_maps = {
    cluster_name                  = get_env("cluster_name")
    cluster_domain                = "${get_env("cluster_name")}.${get_env("domain")}"
    dns_cloud_api_region          = get_env("cloud_region")
    letsencrypt_email             = get_env("letsencrypt_email")
    eks_aws_secret_access_key     = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_SECRET_ACCESS_KEY") : ""
    eks_aws_access_key_id         = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("AWS_ACCESS_KEY_ID") : ""
    eks_aws_region                = (local.K8S_CLUSTER_TYPE == "eks") ? get_env("cloud_region") : ""
    zitadel_terraform_modules_tag = get_env("iac_terraform_modules_tag")
    netbird_terraform_modules_tag = get_env("iac_terraform_modules_tag")
    vault_terraform_modules_tag   = get_env("iac_terraform_modules_tag")
  }
}

include "root" {
  path = find_in_parent_folders()
}
