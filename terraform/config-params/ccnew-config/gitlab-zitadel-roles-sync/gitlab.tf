data "zitadel_user_grants" "active" {
  project_name = var.gitlab_zitadel_project_name
}
data "gitlab_users" "all_users" {
}
data "gitlab_group" "iac" {
  full_path = "iac"
}
data "gitlab_group_membership" "iac" {
  group_id = data.gitlab_group.iac.id
}

resource "gitlab_group_membership" "admin_iac_update" {
  for_each     = local.need_to_update_users
  group_id     = data.gitlab_group.iac.id
  user_id      = each.value.id
  access_level = each.value.is_admin ? "maintainer" : "developer"
}
resource "gitlab_user" "zitadel_users" {
  for_each         = local.need_to_add_users
  name             = each.value.name
  username         = replace(each.value.user_name, "@", "AT")
  email            = each.key
  is_admin         = contains(each.value.role_keys, "gitlab_administrators")
  can_create_group = true
  is_external      = false
  reset_password   = true
}

resource "gitlab_group_membership" "iac_add" {
  for_each     = gitlab_user.zitadel_users
  group_id     = data.gitlab_group.iac.id
  user_id      = each.value.id
  access_level = each.value.is_admin ? "maintainer" : "developer"
}

locals {
  admin_users            = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if contains(tolist(user_grant.role_keys), "gitlab_administrators") }
  non_admin_users        = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if contains(tolist(user_grant.role_keys), "gitlab_users") }
  gitlab_admin_users     = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user if gitlab_user.is_admin }
  gitlab_non_admin_users = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user if !gitlab_user.is_admin }
  all_gitlab_users       = { for gitlab_user in data.gitlab_users.all_users.users : gitlab_user.email => gitlab_user }
  need_to_add_users      = { for user_grant in data.zitadel_user_grants.active.user_grant_data : user_grant.email => user_grant if !contains(keys(local.all_gitlab_users), user_grant.email) }
  need_to_update_users   = { for email, gitlab_user in local.all_gitlab_users : gitlab_user.id => gitlab_user if !contains(data.gitlab_group_membership.iac.members.*.id, gitlab_user.id) }
}

output "zitadel_admin_users" {
  value = local.admin_users
}

output "zitadel_non_admin_users" {
  value = local.non_admin_users
}

output "all_gitlab_users" {
  value = local.all_gitlab_users
}
output "need_to_update_users" {
  value = local.need_to_update_users
}
output "need_to_add_users" {
  value = local.need_to_add_users
}
