output "vault_application_client_id" {
  value     = zitadel_application_oidc.vault_ui.client_id
  sensitive = true
}
output "vault_application_client_secret" {
  value     = zitadel_application_oidc.vault_ui.client_secret
  sensitive = true
}
