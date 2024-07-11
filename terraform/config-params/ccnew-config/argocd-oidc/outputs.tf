output "oidc_client_id" {
  value     = zitadel_application_oidc.argocd.client_id
  sensitive = true
}
output "oidc_client_secret" {
  value     = zitadel_application_oidc.argocd.client_secret
  sensitive = true
}
