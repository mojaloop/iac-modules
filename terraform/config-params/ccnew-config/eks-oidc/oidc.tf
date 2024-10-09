resource "zitadel_project" "eks" {
  name                   = "eks"
  org_id                 = local.org_id
  project_role_assertion = true
}

resource "zitadel_application_oidc" "eks_cli" {
  project_id                  = zitadel_project.eks.id
  org_id                      = local.org_id
  name                        = "eks-cli"
  redirect_uris               = ["http://localhost:8000"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["http://localhost:8000"]
  app_type                    = "OIDC_APP_TYPE_NATIVE"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  version                     = "OIDC_VERSION_1_0"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_project_role" "techops_admin" {
  project_id   = zitadel_project.eks.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "Techops Admin"
}

resource "zitadel_project_role" "techops_user" {
  project_id   = zitadel_project.eks.id
  org_id       = local.org_id
  role_key     = var.user_rbac_group
  display_name = "Techops User"
}

resource "zitadel_user_grant" "zitadel_admin_techops_admin" {
  project_id = zitadel_project.eks.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.techops_admin.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "kubernetes_cluster_role_binding_v1" "oidc_cluster_admin" {
  metadata {
    name = "eks-oidc-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "Group"
    name = "${zitadel_project.eks.id}:${var.admin_rbac_group}"
  }
}

resource "kubernetes_cluster_role_v1" "k8s_user_rbac" {
  metadata {
    name = "eks-oidc-user"
  }
  rule {
    api_groups = [""]
    resources  = ["ResourceAll"]
    verbs      = ["get", "list", "watch"]
  }
}
resource "kubernetes_cluster_role_binding_v1" "k8s_user_rbac" {
  metadata {
    name = "eks-oidc-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "oidc-user"
  }
  subject {
    kind = "Group"
    name = "${zitadel_project.eks.id}:${var.user_rbac_group}"
  }
  depends_on = [kubernetes_cluster_role_v1.k8s_user_rbac]
}

resource "aws_eks_identity_provider_config" "eks_cluster" {
  cluster_name = var.cluster_name

  oidc {
    client_id                     = zitadel_application_oidc.eks_cli.client_id
    identity_provider_config_name = var.identity_provider_config_name
    issuer_url                    = var.kubernetes_oidc_issuer_url
    username_claim                = var.kubernetes_oidc_username_claim
    groups_claim                  = var.kubernetes_oidc_groups_claim
    #username_prefix              = var.kubernetes_oidc_username_prefix
    #groups_prefix                = var.kubernetes_oidc_groups_prefix
  }
}