data "zitadel_user_grants" "active" {
  project_name = var.gitlab_zitadel_project_name
}
data "gitlab_users" "all_users" {
}
data "gitlab_group" "iac" {
  full_path = "iac"
}

#merges map with highest priv last to only give highest access level in membership
resource "gitlab_group_membership" "admin_iac_update" {
  for_each     = merge(local.need_to_add_developer_users_to_group, local.need_to_add_maintainer_users_to_group, local.need_to_add_admin_users_to_group)
  group_id     = data.gitlab_group.iac.id
  user_id      = each.value.gitlab_user_id
  access_level = each.value.gitlab_group_perms
}


locals {
  all_gitlab_users = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user }
  need_to_add_admin_users_to_group = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => {
    gitlab_user_id     = local.all_gitlab_users[user_grant.email].id
    gitlab_group_perms = zitadel_to_gitlab_role_mapvar[var.admin_rbac_group]
  } if contains(keys(local.all_gitlab_users), user_grant.email) && contains(user_grant.role_keys, var.admin_rbac_group) }

  need_to_add_maintainer_users_to_group = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => {
    gitlab_user_id     = local.all_gitlab_users[user_grant.email].id
    gitlab_group_perms = zitadel_to_gitlab_role_mapvar[var.maintainer_rbac_group]
  } if contains(keys(local.all_gitlab_users), user_grant.email) && contains(user_grant.role_keys, var.maintainer_rbac_group) }

  need_to_add_developer_users_to_group = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => {
    gitlab_user_id     = local.all_gitlab_users[user_grant.email].id
    gitlab_group_perms = zitadel_to_gitlab_role_mapvar[var.user_rbac_group]
  } if contains(keys(local.all_gitlab_users), user_grant.email) && contains(user_grant.role_keys, var.user_rbac_group) }

  zitadel_to_gitlab_role_map = {
    var.admin_rbac_group      = "owner"
    var.maintainer_rbac_group = "maintainer"
    var.user_rbac_group       = "developer"
  }
}


output "updated_group_members" {
  value = { for group_membership in gitlab_group_membership.admin_iac_update :
    group_membership.user_id => group_membership.access_level
  }
}
