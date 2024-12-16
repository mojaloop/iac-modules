data "gitlab_group" "iac" {
  full_path = "iac"
}


# environment projects
resource "gitlab_project" "envs" {
  for_each               = local.environment_list
  name                   = each.value
  namespace_id           = data.gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = true
}

resource "gitlab_project_access_token" "envs" {
  for_each     = local.environment_list
  project      = gitlab_project.envs[each.key].id
  name         = "Argocd project access token"
  access_level = "reporter"
  rotation_configuration = {
    expiration_days    = 365
    rotate_before_days = 364
  }

  scopes = ["read_api", "read_registry"]
}


resource "kubernetes_secret_v1" "setup_keys" {
  for_each = local.environment_list
  metadata {
    name      = "${each.value}-repo-secret"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = {
    "type"     = "git"
    "project"  = "default"
    "password" = gitlab_project_access_token.envs[each.key].token
    "url"      = gitlab_project.envs[each.key].http_url_to_repo
    "username" = "${each.value}token"
  }
  type = "Opaque"
}

locals {
  environment_list = toset(split(",", var.environment_list))
}

#environment preq

resource "gitlab_group_variable" "nexus_fqdn" {
  group             = data.gitlab_group.iac.id
  key               = "NEXUS_FQDN"
  value             = var.nexus_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "zitadel_fqdn" {
  group             = data.gitlab_group.iac.id
  key               = "ZITADEL_FQDN"
  value             = var.zitadel_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "nexus_docker_repo_listening_port" {
  group             = data.gitlab_group.iac.id
  key               = "NEXUS_DOCKER_REPO_LISTENING_PORT"
  value             = var.nexus_docker_repo_listening_port
  protected         = true
  masked            = false
  environment_scope = "*"
}

# to be changed
resource "gitlab_group_variable" "ceph_obj_store_gw_fqdn" {
  group             = data.gitlab_group.iac.id
  key               = "CEPH_OBJECTSTORE_FQDN"
  value             = var.ceph_obj_store_gw_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

# to be changed
resource "gitlab_group_variable" "ceph_obj_store_gw_port" {
  group             = data.gitlab_group.iac.id
  key               = "CEPH_OBJECTSTORE_PORT"
  value             = var.ceph_obj_store_gw_port
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "tenant_vault_listening_port" {
  group             = data.gitlab_group.iac.id
  key               = "TENANT_VAULT_LISTENING_PORT"
  value             = var.tenant_vault_listening_port
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kv_secret_path" {
  group             = data.gitlab_group.iac.id
  key               = "KV_SECRET_PATH"
  value             = var.kv_path
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "vault_server_url" {
  group             = data.gitlab_group.iac.id
  key               = "VAULT_SERVER_URL"
  value             = "https://$VAULT_FQDN"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "gitlab_admin_rbac_group" {
  group             = data.gitlab_group.iac.id
  key               = "GITLAB_ADMIN_RBAC_GROUP"
  value             = var.gitlab_admin_rbac_group
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "gitlab_readonly_rbac_group" {
  group             = data.gitlab_group.iac.id
  key               = "GITLAB_READONLY_RBAC_GROUP"
  value             = var.gitlab_readonly_rbac_group
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "netbird_api_host" {
  group             = data.gitlab_group.iac.id
  key               = "NETBIRD_API_HOST"
  value             = "https://${var.netbird_api_host}:443"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "netbird_version" {
  group             = data.gitlab_group.iac.id
  key               = "NETBIRD_VERSION"
  value             = var.netbird_client_version
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kubernetes_oidc_enabled" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_ENABLED"
  value             = "true"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kubernetes_oidc_issuer" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_ISSUER"
  value             = var.zitadel_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kubernetes_oidc_groups_prefix" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_GROUPS_PREFIX"
  value             = ""
  protected         = true
  masked            = false
  environment_scope = "*"
}
resource "gitlab_group_variable" "kubernetes_oidc_username_prefix" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_USERNAME_PREFIX"
  value             = ""
  protected         = true
  masked            = false
  environment_scope = "*"
}
resource "gitlab_group_variable" "kubernetes_oidc_username_claim" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_USERNAME_CLAIM"
  value             = "email"
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "kubernetes_oidc_groups_claim" {
  group             = data.gitlab_group.iac.id
  key               = "KUBERNETES_OIDC_GROUPS_CLAIM"
  value             = var.kubernetes_oidc_groups_claim
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "mimir_gw_fqdn" {
  group             = data.gitlab_group.iac.id
  key               = "MIMIR_GW_FQDN"
  value             = var.mimir_gw_fqdn
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "cc_cidr_block" {
  group             = data.gitlab_group.iac.id
  key               = "CC_CIDR_BLOCK"
  value             = var.cc_cidr_block
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_repository_file" "vault_token_update" {
  for_each       = local.environment_list
  project        = gitlab_project.envs[each.key].id
  file_path      = ".vault_token_trigger"
  branch         = "main"
  content        = base64encode("vault-token-${sha256(vault_token.env_token[each.value].client_token)}")
  author_name    = "Terraform"
  commit_message = "tf_trigger: vault_token_update"
}
