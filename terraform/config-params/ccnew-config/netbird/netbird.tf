resource "zitadel_project" "netbird" {
  name   = "NETBIRD"
  org_id = local.org_id
}

resource "zitadel_application_oidc" "netbird_dashboard" {
  project_id                  = zitadel_project.netbird.id
  org_id                      = local.org_id
  name                        = "Netbird-Dashboard"
  redirect_uris               = ["https://${var.dashboard_fqdn}/nb-auth", "https://${var.dashboard_fqdn}/nb-silent-auth"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  post_logout_redirect_uris   = ["https://${var.dashboard_fqdn}/"]
  app_type                    = "OIDC_APP_TYPE_USER_AGENT"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  version                     = "OIDC_VERSION_1_0"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
}

resource "zitadel_application_oidc" "netbird_cli" {
  project_id                  = zitadel_project.netbird.id
  org_id                      = local.org_id
  name                        = "Netbird-Cli"
  redirect_uris               = ["http://localhost:53000/", "http://localhost:54000/"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_DEVICE_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  post_logout_redirect_uris   = ["http://localhost:53000/"]
  app_type                    = "OIDC_APP_TYPE_USER_AGENT"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  version                     = "OIDC_VERSION_1_0"
  dev_mode                    = true
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
}


resource "zitadel_machine_user" "service_user" {
  org_id            = local.org_id
  user_name         = "netbird-service-account"
  name              = "Netbird Service Account"
  description       = "Netbird Service Account for IDP management"
  with_secret       = true
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}

resource "zitadel_org_member" "service_user_role" {
  org_id  = local.org_id
  user_id = zitadel_machine_user.service_user.id
  roles   = ["ORG_OWNER"]
}
