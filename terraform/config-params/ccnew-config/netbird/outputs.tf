output "netbird_client_id" {
  value     = zitadel_application_oidc.netbird.client_id
  sensitive = true
}
output "netbird_cli_client_id" {
  value     = zitadel_application_oidc.netbird_cli.client_id
  sensitive = true
}
output "netbird_service_user_client_id" {
  value     = zitadel_machine_user.service_user.client_id
  sensitive = true
}
output "netbird_service_user_client_secret" {
  value     = zitadel_machine_user.service_user.client_secret
  sensitive = true
}

output "netbird_api_admin_user_client_id" {
  value     = zitadel_machine_user.netbird_api_admin.client_id
  sensitive = true
}
output "netbird_api_admin_user_client_secret" {
  value     = zitadel_machine_user.netbird_api_admin.client_secret
  sensitive = true
}

output "netbird_project_id" {
  value = zitadel_project.netbird.id
}
