output "gitlab_application_client_id" {
  value     = zitadel_application_oidc.gitlab.client_id
  sensitive = true
}
