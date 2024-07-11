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
