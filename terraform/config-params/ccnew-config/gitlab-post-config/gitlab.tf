resource "gitlab_group" "gitlab_admin_rbac_group" {
  name        = var.gitlab_admin_rbac_group
  path        = var.gitlab_admin_rbac_group
  description = "${var.gitlab_admin_rbac_group} group"
}

resource "gitlab_group" "gitlab_readonly_rbac_group" {
  name        = var.gitlab_readonly_rbac_group
  path        = var.gitlab_readonly_rbac_group
  description = "${var.gitlab_readonly_rbac_group} group"
}

resource "gitlab_group" "iac" {
  name                              = "iac"
  path                              = "iac"
  description                       = "iac group"
  require_two_factor_authentication = true
  two_factor_grace_period           = var.two_factor_grace_period
}

resource "gitlab_project" "bootstrap" {
  name                   = "bootstrap"
  namespace_id           = gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = true
}