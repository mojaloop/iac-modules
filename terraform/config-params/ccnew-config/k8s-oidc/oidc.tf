resource "zitadel_project" "k8s" {
  name                   = "k8s"
  org_id                 = local.org_id
  project_role_assertion = true
}

resource "zitadel_application_oidc" "k8s_cli" {
  project_id                  = zitadel_project.k8s.id
  org_id                      = local.org_id
  name                        = "k8s-cli"
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
}


resource "zitadel_project_role" "techops_admin" {
  project_id   = zitadel_project.k8s.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "Techops Admin"
}

resource "zitadel_project_role" "techops_user" {
  project_id   = zitadel_project.k8s.id
  org_id       = local.org_id
  role_key     = var.user_rbac_group
  display_name = "Techops User"
}

resource "zitadel_user_grant" "zitadel_admin_techops_admin" {
  project_id = zitadel_project.k8s.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.techops_admin.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "kubernetes_cluster_role_binding_v1" "oidc_cluster_admin" {
  metadata {
    name = "oidc-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "Group"
    name = "${zitadel_project.k8s.id}:${var.admin_rbac_group}"
  }
}

resource "kubernetes_cluster_role_v1" "k8s_user_rbac" {
  metadata {
    name = "oidc-user"
  }
  rule {
    api_groups = [""]
    resources  = ["ResourceAll"]
    verbs      = ["get", "list", "watch"]
  }
}
resource "kubernetes_cluster_role_binding_v1" "k8s_user_rbac" {
  metadata {
    name = "oidc-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "oidc-user"
  }
  subject {
    kind = "Group"
    name = "${zitadel_project.k8s.id}:${var.user_rbac_group}"
  }
  depends_on = [kubernetes_cluster_role_v1.k8s_user_rbac]
}
