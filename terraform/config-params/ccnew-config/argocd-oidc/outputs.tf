output "oidc_client_id" {
  value     = zitadel_application_oidc.argocd.client_id
  sensitive = true
}
