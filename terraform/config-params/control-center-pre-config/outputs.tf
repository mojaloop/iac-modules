output "netmaker_hosts_var_maps" {
  sensitive = true
  value = {
    netmaker_oidc_client_id     = var.enable_netmaker_oidc ? gitlab_application.netmaker_oidc[0].application_id : ""
    netmaker_oidc_client_secret = var.enable_netmaker_oidc ? gitlab_application.netmaker_oidc[0].secret : ""
  }
}

output "docker_hosts_var_maps" {
  sensitive = true
  value = {
    vault_oidc_client_id        = var.enable_vault_oidc ? gitlab_application.tenant_vault_oidc[0].application_id : ""
    vault_oidc_client_secret    = var.enable_vault_oidc ? gitlab_application.tenant_vault_oidc[0].secret : ""
    gitlab_bootstrap_project_id = gitlab_project.bootstrap.id
    dex_oidc_client_id          = gitlab_application.dex_oidc.application_id
    dex_oidc_client_secret      = gitlab_application.dex_oidc.secret
    dex_fqdn                    = var.dex_fqdn
    dex_oidc_admin_group        = var.gitlab_admin_rbac_group
  }
}

output "bootstrap_project_id" {
  value = gitlab_project.bootstrap.id
}

output "iac_group_id" {
  value = gitlab_group.iac.id
}
