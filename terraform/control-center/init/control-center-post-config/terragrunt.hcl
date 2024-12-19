terraform {
  source = "git::https://github.com/thitsax/mojaloop-iac-modules.git//terraform/config-params/control-center-post-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible_cc_post_deploy" {
  config_path = "../ansible-cc-post-deploy"
  mock_outputs = {
    vault_root_token = "temporary-dummy-id"
    netmaker_token_map = {
      for key in keys(local.env_map) : "${key}-k8s" => {
        netmaker_token = "tempid"
      }
    }
    netmaker_control_network_name = ""
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "deep_map_only"
}
# dependency "control_center_deploy" {
#   config_path = "../control-center-deploy"
#   mock_outputs = {
#     vault_fqdn             = "temporary-dummy-id"
#     gitlab_root_token      = "temporary-dummy-id"
#     gitlab_server_hostname = "temporary-dummy-id"
#     public_zone_name       = "temporary-dummy-id"
#     netmaker_hosts_var_maps = {
#       netmaker_master_key = "test"
#     }
#     bastion_hosts_var_maps = {
#       netmaker_host_name = "test"
#       netmaker_api_host  = "test"
#     }
#     minio_server_url      = "temporary-dummy-id"
#     minio_root_user       = "temporary-dummy-id"
#     minio_root_password   = "temporary-dummy-id"
#   }
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
#   mock_outputs_merge_strategy_with_state  = "deep_map_only"
# }

dependency "control_center_pre_config" {
  config_path = "../control-center-pre-config"
  mock_outputs = {
    iac_group_id = "temporary-dummy-id"
    docker_hosts_var_maps = {
      vault_oidc_client_id     = "temporary-dummy-id"
      vault_oidc_client_secret = "temporary-dummy-id"
    }

  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  gitlab_admin_rbac_group       = local.env_vars.gitlab_admin_rbac_group
  gitlab_hostname               = local.gitlab_env_map["server_hostname"]
  vault_oauth_app_client_id     = dependency.control_center_pre_config.outputs.docker_hosts_var_maps["vault_oidc_client_id"]
  vault_oauth_app_client_secret = dependency.control_center_pre_config.outputs.docker_hosts_var_maps["vault_oidc_client_secret"]
  vault_fqdn                    = local.docker_env_map["vault_fqdn"]
  env_map = merge(local.env_map,
    { for key in keys(local.env_map) : key => merge(local.env_map[key], {
      netmaker_ops_token        = try(dependency.ansible_cc_post_deploy.outputs.netmaker_token_map["${dependency.ansible_cc_post_deploy.outputs.netmaker_control_network_name}-ops"].netmaker_token, "")
      netmaker_env_token        = try(dependency.ansible_cc_post_deploy.outputs.netmaker_token_map["${key}-k8s"].netmaker_token, "")
      netmaker_env_network_name = try(dependency.ansible_cc_post_deploy.outputs.netmaker_token_map["${key}-k8s"].network, "")
      })
  })
  iac_group_id        = dependency.control_center_pre_config.outputs.iac_group_id
  gitlab_root_token   = local.gitlab_env_map["server_token"]
  vault_root_token    = dependency.ansible_cc_post_deploy.outputs.vault_root_token
  netmaker_master_key = local.env_vars.netmaker_hosts_var_maps["netmaker_master_key"]
  netmaker_host_name  = local.env_vars.bastion_hosts_var_maps["netmaker_api_host"]
  netmaker_version    = local.env_vars.netmaker_version
  gitlab_admin_rbac_group          = local.env_vars.gitlab_admin_rbac_group
  gitlab_readonly_rbac_group       = local.env_vars.gitlab_readonly_rbac_group
  loki_data_expiry                 = local.env_vars.loki_data_expiry
  tempo_data_expiry_days           = local.env_vars.tempo_data_expiry_days
  longhorn_backup_data_expiry      = local.env_vars.longhorn_backup_data_expiry 
  velero_data_expiry               = local.env_vars.velero_data_expiry 
  percona_data_expiry              = local.env_vars.percona_backup_data_expiry   
  private_subdomain_string         = local.private_subdomain_string
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  docker_hosts_var_maps = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  docker_env_map = {
    for key, value in local.docker_hosts_var_maps.docker_hosts_var_maps : key => value
  }
  gitlab_hosts_var_maps = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  gitlab_env_map = {
    for key, value in local.gitlab_hosts_var_maps.gitlab_hosts_var_maps : key => value
  }
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )
  env_map = { for val in local.env_vars.envs :
    val["env"] => {
      domain                 = val["domain"]
      vault_oidc_domain      = try(val["vault_oidc_domain"],"")
      grafana_oidc_domain    = try(val["grafana_oidc_domain"],"")
      argocd_oidc_domain     = try(val["argocd_oidc_domain"],"")
    }
  }
  private_subdomain_string = "int"
}

include "root" {
  path = find_in_parent_folders()
}

generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "${local.common_vars.gitlab_provider_version}"
    }
    vault = "${local.common_vars.vault_provider_version}"
    minio = {
      source = "aminueza/minio"
      version = "${local.common_vars.minio_provider_version}" 
    }
  }
}
provider "vault" {
  address = "https://${local.docker_env_map["vault_fqdn"]}"
  token   = "${dependency.ansible_cc_post_deploy.outputs.vault_root_token}"
}
provider "gitlab" {
  token = "${local.gitlab_env_map["server_token"]}"
  base_url = "https://${local.gitlab_env_map["server_hostname"]}"
}
provider "minio" {
  minio_server   = "${local.docker_env_map["minio_server_host"]}:${local.docker_env_map["minio_listening_port"]}"
  minio_user     = "${local.docker_env_map["minio_root_user"]}"
  minio_password = "${local.docker_env_map["minio_root_password"]}"
}
EOF
}
