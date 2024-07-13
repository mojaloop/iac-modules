resource "zitadel_project" "argocd" {
  name                   = "argocd"
  org_id                 = local.org_id
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_application_oidc" "argocd" {
  project_id                  = zitadel_project.argocd.id
  org_id                      = local.org_id
  name                        = "argocd"
  redirect_uris               = ["https://${var.argocd_fqdn}/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["https://${var.argocd_fqdn}"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version                     = "OIDC_VERSION_1_0"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = []
}

resource "zitadel_project_role" "argocd_admins_role" {
  project_id   = zitadel_project.argocd.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "ArgoCd Admins"
}

resource "zitadel_project_role" "argocd_users_role" {
  project_id   = zitadel_project.argocd.id
  org_id       = local.org_id
  role_key     = var.user_rbac_group
  display_name = "ArgoCd Users"
}
resource "kubernetes_secret_v1" "oidc_config" {
  metadata {
    name      = var.oidc_secret_name
    namespace = var.argocd_namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    oidc_client_id     = zitadel_application_oidc.argocd.client_id
    oidc_client_secret = zitadel_application_oidc.argocd.client_secret
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1_data" "argocd_rbac_cm" {
  force = true
  metadata {
    name      = "argocd-rbac-cm"
    namespace = var.argocd_namespace
  }

  data = {
    "policy.csv" = local.policy
  }


}

resource "kubernetes_config_map_v1_data" "argocd_cm" {
  force = true
  metadata {
    name      = "argocd-cm"
    namespace = var.argocd_namespace
  }

  data = {
    "oidc.config" = local.oidc_config
  }

  depends_on = [kubernetes_secret_v1.oidc_config]
}
locals {
  policy      = <<EOF
g, ${zitadel_project.argocd.id}:${var.admin_rbac_group}, role:admin
g, ${zitadel_project.argocd.id}:${var.user_rbac_group}, role:readonly
EOF
  oidc_config = <<EOF
name: Zitadel
issuer: https://${var.zitadel_fqdn}
clientID: ${join("$", kubernetes_secret_v1.oidc_config.metadata.name, ":oidc_client_id")}
clientSecret: ${join("$", kubernetes_secret_v1.oidc_config.metadata.name, ":oidc_client_secret")}
requestedScopes:
  - openid
  - profile
  - email
  - groups
logoutURL: https://${var.zitadel_fqdn}/oidc/v1/end_session
EOF
}
