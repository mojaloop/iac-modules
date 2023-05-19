output "netmaker_hosts_var_maps" {
  sensitive = true
  value = {
    netmaker_oidc_client_id     = var.enable_netmaker_oidc ? gitlab_application.netmaker_oidc[0].application_id : ""
    netmaker_oidc_client_secret = var.enable_netmaker_oidc ? gitlab_application.netmaker_oidc[0].secret : ""
  }
}
output "bootstrap_project_id" {
  value = gitlab_project.bootstrap.id
}

output "iac_group_id" {
  value = gitlab_group.iac.id
}