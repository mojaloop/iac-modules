data "zitadel_orgs" "active" {
  state = "ORG_STATE_ACTIVE"
}

data "zitadel_org" "default" {
  for_each = toset(data.zitadel_orgs.active.ids)
  id       = each.value
}


locals {
  org_id = [for org in data.zitadel_org.default : org.id if org.is_default][0]
}


resource "zitadel_project" "env" {
  name                   = var.env_name
  org_id                 = local.org_id
  project_role_assertion = true
  project_role_check     = true
}


resource "zitadel_application_oidc" "grafana" {
  project_id                  = zitadel_project.env.id
  org_id                      = local.org_id
  name                        = "${var.env_name}-grafana"
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

resource "vault_kv_secret_v2" "env_grafana_oidc_client_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/grafana_oidc_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.grafana.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_grafana_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/grafana_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.grafana.client_secret

    }
  )
}

resource "zitadel_application_oidc" "vault_ui" {
  project_id                  = zitadel_project.env.id
  org_id                      = local.org_id
  name                        = "${var.env_name}-vault-ui"
  redirect_uris               = ["https://${var.vault_fqdn}/ui/vault/auth/oidc/oidc/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["https://${var.vault_fqdn}/ui"]
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

resource "vault_kv_secret_v2" "env_vault_oidc_client_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/vault_oidc_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.vault_ui.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_vault_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/vault_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.vault_ui.client_secret

    }
  )
}

resource "zitadel_application_oidc" "argocd" {
  project_id                  = zitadel_project.env.id
  org_id                      = local.org_id
  name                        = "${var.env_name}-argocd"
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

resource "vault_kv_secret_v2" "env_argocd_oidc_client_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/argocd_oidc_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.argocd.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_argocd_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/argocd_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value     = zitadel_application_oidc.argocd.client_secret

    }
  )
}