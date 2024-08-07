data "gitlab_group" "iac" {
  full_path = "iac"
}


# environment projects
resource "gitlab_project" "envs" {
  for_each               = toset(local.environment_list)
  name                   = each.value
  namespace_id           = data.gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = true
}

locals {
  environment_list = split("," , trimsuffix(var.environment_list, ","))
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