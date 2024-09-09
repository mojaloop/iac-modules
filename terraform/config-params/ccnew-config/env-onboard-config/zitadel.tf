data "zitadel_orgs" "active" {
  state = "ORG_STATE_ACTIVE"
}

data "zitadel_org" "default" {
  for_each = toset(data.zitadel_orgs.active.ids)
  id       = each.value
}


locals {
  org_id             = [for org in data.zitadel_org.default : org.id if org.is_default][0]
  netbird_project_id = [for project_id in data.zitadel_projects.netbird.project_ids : project_id][0]
}

#find the netbird project id
data "zitadel_projects" "netbird" {
  org_id      = local.org_id
  name        = "netbird"
  name_method = "TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE"
}


#make a role inside netbird project for regular env vpn users
resource "zitadel_project_role" "env_vpn_user" {
  project_id   = local.netbird_project_id
  org_id       = local.org_id
  role_key     = "${var.env_name}-vpn-users"
  display_name = "${var.env_name}-vpn-users"
}

#create zitadel project for env to house oidc apps and related roles
resource "zitadel_project" "env" {
  name                   = var.env_name
  org_id                 = local.org_id
  project_role_assertion = true
  project_role_check     = true
}

resource "gitlab_project_variable" "zitadel_project_id" {
  project   = data.gitlab_project.env.id
  key       = "zitadel_project_id"
  value     = zitadel_project.env.id
  protected = false
  masked    = false
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
      value = zitadel_application_oidc.grafana.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_grafana_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/grafana_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = zitadel_application_oidc.grafana.client_secret

    }
  )
}

resource "zitadel_project_role" "grafana_admins_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.grafana_admin_rbac_group
  display_name = "Grafana Admins"
}

resource "gitlab_project_variable" "grafana_admin_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "grafana_admin_rbac_group"
  value     = var.grafana_admin_rbac_group
  protected = false
  masked    = false
}


resource "zitadel_project_role" "grafana_users_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.grafana_user_rbac_group
  display_name = "Grafana Users"
}

resource "gitlab_project_variable" "grafana_user_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "grafana_user_rbac_group"
  value     = var.grafana_user_rbac_group
  protected = false
  masked    = false
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
      value = zitadel_application_oidc.vault_ui.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_vault_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/vault_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = zitadel_application_oidc.vault_ui.client_secret

    }
  )
}

resource "zitadel_project_role" "vault_admins_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.vault_admin_rbac_group
  display_name = "Vault Admins"
}

resource "gitlab_project_variable" "vault_admin_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "vault_admin_rbac_group"
  value     = var.vault_admin_rbac_group
  protected = false
  masked    = false
}

resource "zitadel_project_role" "vault_users_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.vault_user_rbac_group
  display_name = "Vault Users"
}

resource "gitlab_project_variable" "vault_user_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "vault_user_rbac_group"
  value     = var.vault_user_rbac_group
  protected = false
  masked    = false
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
      value = zitadel_application_oidc.argocd.client_id

    }
  )
}

resource "vault_kv_secret_v2" "env_argocd_oidc_client_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/argocd_oidc_client_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = zitadel_application_oidc.argocd.client_secret

    }
  )
}

resource "zitadel_user_grant" "zitadel_env_admin_grant" {
  project_id = zitadel_project.env.id
  org_id     = local.org_id
  role_keys  = [zitadel_project_role.argocd_admins_role.role_key, zitadel_project_role.vault_admins_role.role_key, zitadel_project_role.grafana_admins_role.role_key,zitadel_project_role.k8s_techops_admin.role_key]
  user_id    = var.zitadel_admin_human_user_id
}

resource "zitadel_project_role" "argocd_admins_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.argocd_admin_rbac_group
  display_name = "Argocd Admins"
}

resource "gitlab_project_variable" "argocd_admin_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "argocd_admin_rbac_group"
  value     = var.argocd_admin_rbac_group
  protected = false
  masked    = false
}

resource "zitadel_project_role" "argocd_users_role" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.argocd_user_rbac_group
  display_name = "Argocd Users"
}

resource "gitlab_project_variable" "argocd_user_rbac_group" {
  project   = data.gitlab_project.env.id
  key       = "argocd_user_rbac_group"
  value     = var.argocd_user_rbac_group
  protected = false
  masked    = false
}


resource "zitadel_application_oidc" "k8s_cli" {
  project_id                  = zitadel_project.env.id
  org_id                      = local.org_id
  name                        = "${var.env_name}-k8s-cli"
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


resource "zitadel_project_role" "k8s_techops_admin" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.k8s_admin_rbac_group
  display_name = "Techops Admin"
}

resource "zitadel_project_role" "k8s_techops_user" {
  project_id   = zitadel_project.env.id
  org_id       = local.org_id
  role_key     = var.k8s_user_rbac_group
  display_name = "Techops User"
}


resource "vault_kv_secret_v2" "env_k8s_oidc_client_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/kubernetes_oidc_client_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = zitadel_application_oidc.k8s_cli.client_id
    }
  )
}

resource "gitlab_project_variable" "kubernetes_oidc_k8s_admin_group" {
  project   = data.gitlab_project.env.id
  key       = "KUBERNETES_OIDC_K8S_ADMIN_GROUP"
  value     = "${zitadel_project.env.id}:${var.k8s_admin_rbac_group}"
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "kubernetes_oidc_k8s_user_group" {
  project   = data.gitlab_project.env.id
  key       = "KUBERNETES_OIDC_K8S_USER_GROUP"
  value     = "${zitadel_project.env.id}:${var.k8s_user_rbac_group}"
  protected = false
  masked    = false
}
