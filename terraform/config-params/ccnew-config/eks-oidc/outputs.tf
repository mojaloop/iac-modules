output "kubernetes_oidc_client_id" {
  value     = zitadel_application_oidc.eks_cli.client_id
  sensitive = true
}

output "k8s_project_id" {
  value = zitadel_project.eks.id
}

output "kubernetes_oidc_issuer" {
  value = "https://${var.zitadel_fqdn}"
}