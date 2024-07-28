resource "zitadel_project" "grafana" {
  name                   = "grafana"
  org_id                 = local.org_id
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_application_oidc" "grafana" {
  project_id                  = zitadel_project.grafana.id
  org_id                      = local.org_id
  name                        = "grafana"
  redirect_uris               = ["https://${var.grafana_fqdn}/login/generic_oauth"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  post_logout_redirect_uris   = ["https://${var.grafana_fqdn}"]
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

resource "zitadel_user_grant" "zitadel_admin_grafana_admin" {
  project_id = zitadel_project.grafana.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.grafana_admins_role.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "zitadel_project_role" "grafana_admins_role" {
  project_id   = zitadel_project.grafana.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "Grafana Admins"
}

resource "zitadel_project_role" "grafana_users_role" {
  project_id   = zitadel_project.grafana.id
  org_id       = local.org_id
  role_key     = var.user_rbac_group
  display_name = "Grafana Users"
}

resource "grafana_sso_settings" "zitadel_sso_settings" {
  provider_name = "generic_oauth"
  oauth2_settings {
    name                  = "Zitadel"
    auth_url              = "https://${var.zitadel_fqdn}/oauth/v2/authorize"
    token_url             = "https://${var.zitadel_fqdn}/oauth/v2/token"
    api_url               = "https://${var.zitadel_fqdn}/oidc/v1/userinfo"
    client_id             = zitadel_application_oidc.grafana.client_id
    client_secret         = zitadel_application_oidc.grafana.client_secret
    allow_sign_up         = true
    auto_login            = false
    scopes                = "openid profile email groups zitadel:grants"
    use_pkce              = true
    use_refresh_token     = true
    role_attribute_path   = "is_admin && 'Admin' || 'Viewer'"
    groups_attribute_path = var.oidc_provider_group_claim_prefix
    allowed_groups        = "${zitadel_project.grafana.id}:${var.user_rbac_group},${zitadel_project.grafana.id}:${var.admin_rbac_group}"
  }
}





