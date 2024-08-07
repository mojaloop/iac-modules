data "zitadel_user_grants" "active" {
  project_name = var.gitlab_zitadel_project_name
}
data "gitlab_users" "all_users" {
}
data "gitlab_group" "iac" {
  full_path = "iac"
}

resource "gitlab_group_membership" "admin_iac_update" {
  for_each     = local.need_to_add_users_to_group
  group_id     = data.gitlab_group.iac.id
  user_id      = each.value.gitlab_user_id
  access_level = each.value.gitlab_group_perms
}


locals {
  #admin_users            = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if contains(tolist(user_grant.role_keys), "gitlab_administrators") }
  #non_admin_users        = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if contains(tolist(user_grant.role_keys), "gitlab_users") }
  #gitlab_admin_users     = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user if gitlab_user.is_admin }
  #gitlab_non_admin_users = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user if !gitlab_user.is_admin }
  all_gitlab_users = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user }
  need_to_add_users_to_group = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => {
    gitlab_user_id     = local.all_gitlab_users[user_grant.email].id
    gitlab_group_perms = contains(user_grant.role_keys, "gitlab_administrators") ? "maintainer" : "developer"
  } if contains(keys(local.all_gitlab_users), user_grant.email) }
  #need_to_add_users      = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if contains(keys(local.all_gitlab_users), user_grant.email) && !contains(data.gitlab_group_membership.iac.members.*.id, gitlab_user.id)}
  #need_to_update_users   = { for email, gitlab_user in local.all_gitlab_users : gitlab_user.id => gitlab_user if !contains(data.gitlab_group_membership.iac.members.*.id, gitlab_user.id) }
}



output "all_gitlab_users" {
  value = local.all_gitlab_users
}
output "need_to_add_users_to_group" {
  value = local.need_to_add_users_to_group
}
