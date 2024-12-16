output "kubernetes_oidc_client_id" {
  value     = zitadel_application_oidc.k8s_cli.client_id
  sensitive = true
}

output "k8s_project_id" {
  value = zitadel_project.k8s.id
}

output "kubernetes_oidc_issuer" {
  value = "https://${var.zitadel_fqdn}"
}

