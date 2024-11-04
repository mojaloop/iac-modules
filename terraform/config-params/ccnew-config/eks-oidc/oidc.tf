resource "aws_eks_identity_provider_config" "eks_cluster" {
  cluster_name = var.cluster_name

  oidc {
    client_id                     = var.kubernetes_oidc_client_id
    identity_provider_config_name = var.identity_provider_config_name
    issuer_url                    = "https://${var.zitadel_fqdn}"
    username_claim                = var.kubernetes_oidc_username_claim
    groups_claim                  = var.kubernetes_oidc_groups_claim
    #username_prefix              = var.kubernetes_oidc_username_prefix
    #groups_prefix                = var.kubernetes_oidc_groups_prefix
  }
}