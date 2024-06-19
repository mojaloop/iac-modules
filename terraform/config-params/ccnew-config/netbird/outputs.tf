output "netbird_dashboard_client_id" {
  value     = zitadel_application_oidc.netbird_dashboard.client_id
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
