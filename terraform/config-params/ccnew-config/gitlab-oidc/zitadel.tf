resource "zitadel_project" "gitlab" {
  name                   = var.gitlab_zitadel_project_name
  org_id                 = local.org_id
  project_role_assertion = true
}

resource "zitadel_application_oidc" "gitlab" {
  project_id                  = zitadel_project.gitlab.id
  org_id                      = local.org_id
  name                        = "gitlab"
  redirect_uris               = ["https://${var.gitlab_fqdn}/users/auth/openid_connect/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["https://${var.gitlab_fqdn}/"]
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

resource "zitadel_project_role" "techops_admin" {
  project_id   = zitadel_project.gitlab.id
  org_id       = local.org_id
  role_key     = var.admin_rbac_group
  display_name = "Techops Admin"
}

resource "zitadel_project_role" "techops_maintainer" {
  project_id   = zitadel_project.gitlab.id
  org_id       = local.org_id
  role_key     = var.maintainer_rbac_group
  display_name = "Techops IaC Maintainer"
}

resource "zitadel_project_role" "techops_user" {
  project_id   = zitadel_project.gitlab.id
  org_id       = local.org_id
  role_key     = var.user_rbac_group
  display_name = "Techops User"
}

resource "zitadel_user_grant" "zitadel_admin_gitlab_admin" {
  project_id = zitadel_project.gitlab.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.techops_admin.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "kubernetes_secret_v1" "oidc_config" {
  metadata {
    name      = var.oidc_secret_name
    namespace = var.gitlab_namespace
    labels = {
      "app.kubernetes.io/part-of" = "gitlab"
      "reloader"                  = "enabled"
    }
  }

  data = {
    "provider" = jsonencode({
      "name"  = "openid_connect"
      "label" = "Zitadel"
      "icon"  = "https://${var.zitadel_fqdn}/ui/console/assets/icons/favicon-32x32.png"
      "args" = {
        "name"               = "openid_connect"
        "scope"              = ["openid", "profile", "email", "groups"]
        "response_type"      = "code"
        "issuer"             = "https://${var.zitadel_fqdn}"
        "discovery"          = true
        "client_auth_method" = "query"
        "client_options" = {
          "identifier"             = zitadel_application_oidc.gitlab.client_id
          "secret"                 = zitadel_application_oidc.gitlab.client_secret
          "host"                   = var.zitadel_fqdn
          "redirect_uri"           = "https://${var.gitlab_fqdn}/users/auth/openid_connect/callback"
          "authorization_endpoint" = "https://${var.zitadel_fqdn}/oauth/v2/authorize"
          "token_endpoint"         = "https://${var.zitadel_fqdn}/oauth/v2/token"
          "userinfo_endpoint"      = "https://${var.zitadel_fqdn}/oidc/v1/userinfo"
          "jwks_uri"               = "https://${var.zitadel_fqdn}/oauth/v2/keys"
          "gitlab" = {
            "groups_attribute" = "${var.oidc_provider_group_claim_prefix}"
            "admin_groups"     = ["${zitadel_project.gitlab.id}:${var.admin_rbac_group}"]
          }
        }
      }
    })
  }

  type = "Opaque"
}
