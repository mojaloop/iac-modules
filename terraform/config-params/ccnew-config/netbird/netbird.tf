resource "zitadel_project" "netbird" {
  name                   = "Netbird"
  org_id                 = local.org_id
  project_role_assertion = true
}

resource "zitadel_application_oidc" "netbird" {
  project_id                  = zitadel_project.netbird.id
  org_id                      = local.org_id
  name                        = "netbird"
  redirect_uris               = ["https://${var.dashboard_fqdn}/nb-auth", "https://${var.dashboard_fqdn}/nb-silent-auth", "http://localhost:53000"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN", "OIDC_GRANT_TYPE_DEVICE_CODE"]
  post_logout_redirect_uris   = ["https://${var.dashboard_fqdn}/"]
  app_type                    = "OIDC_APP_TYPE_USER_AGENT"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  version                     = "OIDC_VERSION_1_0"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
}

# resource "zitadel_application_oidc" "netbird_cli" {
#   project_id                  = zitadel_project.netbird.id
#   org_id                      = local.org_id
#   name                        = "Netbird-Cli"
#   redirect_uris               = ["http://localhost:53000/", "http://localhost:54000/"]
#   response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
#   grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_DEVICE_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
#   post_logout_redirect_uris   = ["http://localhost:53000/"]
#   app_type                    = "OIDC_APP_TYPE_USER_AGENT"
#   auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
#   version                     = "OIDC_VERSION_1_0"
#   dev_mode                    = true
#   access_token_type           = "OIDC_TOKEN_TYPE_JWT"
#   access_token_role_assertion = true
# }


resource "zitadel_machine_user" "service_user" {
  org_id            = local.org_id
  user_name         = "netbird"
  name              = "netbird"
  description       = "Netbird Service Account for IDP management"
  with_secret       = true
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}

resource "zitadel_org_member" "service_user_role" {
  org_id  = local.org_id
  user_id = zitadel_machine_user.service_user.id
  roles   = ["ORG_USER_MANAGER"]
}

resource "zitadel_project_role" "techops_admin" {
  project_id   = zitadel_project.netbird.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "Techops Admin"
}

resource "zitadel_user_grant" "zitadel_admin_argocd_admin" {
  project_id = zitadel_project.netbird.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.techops_admin.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "zitadel_machine_user" "netbird_api_admin" {
  org_id            = local.org_id
  user_name         = "netbird-api-admin"
  name              = "netbird-api-admin"
  description       = "Netbird API admin user"
  with_secret       = true
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}
