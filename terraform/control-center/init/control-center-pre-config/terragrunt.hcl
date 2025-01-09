terraform {
  source = "git::https://github.com/thitsax/mojaloop-iac-modules.git//terraform/config-params/control-center-pre-config?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}
dependency "ansible-cc-deploy" {
  config_path  = "../ansible-cc-deploy"
  skip_outputs = true
}
# dependency "control_center_deploy" {
#   config_path = "../control-center-deploy"
#   mock_outputs = {
#     iac_user_key_secret              = "temporary-dummy-id"
#     iac_user_key_id                  = "temporary-dummy-id"
#     gitlab_root_token                = "temporary-dummy-id"
#     gitlab_server_hostname           = "temporary-dummy-id"
#     netmaker_oidc_callback_url       = "temporary-dummy-id"
#     minio_listening_port             = "temporary-dummy-id"
#     nexus_docker_repo_listening_port = "temporary-dummy-id"
#     minio_fqdn                       = "temporary-dummy-id"
#     mimir_fqdn                       = "temporary-dummy-id"
#     mimir_listening_port             = "temporary-dummy-id"
#     nexus_fqdn                       = "temporary-dummy-id"
#     tenant_vault_listening_port      = "temporary-dummy-id"
#     vault_fqdn                       = "temporary-dummy-id"
    
#     central_observability_grafana_server_url = "temporary-dummy-id"
#   }
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
#   mock_outputs_merge_strategy_with_state  = "shallow"
# }

inputs = {
  iac_user_key_secret              = local.env_vars.iac_user_key_secret
  iac_user_key_id                  = local.env_vars.iac_user_key_id
  gitlab_admin_rbac_group          = local.env_vars.gitlab_admin_rbac_group
  gitlab_readonly_rbac_group       = local.env_vars.gitlab_readonly_rbac_group
  enable_netmaker_oidc             = local.netmaker_env_map["enable_oauth"]
  netmaker_oidc_redirect_url       = local.netmaker_env_map["netmaker_oidc_redirect_url"]
  minio_listening_port             = local.docker_env_map["minio_listening_port"]
  nexus_docker_repo_listening_port = local.docker_env_map["nexus_docker_repo_listening_port"]
  minio_fqdn                       = local.docker_env_map["minio_server_host"]
  mimir_fqdn                       = local.docker_env_map["mimir_fqdn"]
  mimir_listening_port             = local.docker_env_map["mimir_listening_port"]
  nexus_fqdn                       = local.docker_env_map["nexus_fqdn"]
  tenant_vault_listening_port      = local.docker_env_map["vault_listening_port"]
  vault_fqdn                       = local.docker_env_map["vault_fqdn"]
  private_repo_user                = get_env("PRIVATE_REPO_USER")
  private_repo_token               = get_env("PRIVATE_REPO_TOKEN")
  private_repo                     = get_env("PRIVATE_REPO")
  iac_templates_tag                = get_env("IAC_TEMPLATES_TAG")
  iac_terraform_modules_tag        = get_env("IAC_TERRAFORM_MODULES_TAG")

  enable_central_observability_grafana_oidc       = local.docker_env_map["enable_central_observability_grafana_oidc"]
  central_observability_grafana_oidc_redirect_url = "https://${local.docker_env_map["central_observability_grafana_fqdn"]}/login/gitlab"
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
  netmaker_hosts_var_maps = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  netmaker_env_map = {
    for key, value in local.netmaker_hosts_var_maps.netmaker_hosts_var_maps : key => value
  }
  common_vars = yamldecode(
    file("${find_in_parent_folders("common-vars.yaml")}")
  )

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
  }
}
provider "gitlab" {
  token = "${local.gitlab_env_map["server_token"]}"
  base_url = "https://${local.gitlab_env_map["server_hostname"]}"
}
EOF
}
