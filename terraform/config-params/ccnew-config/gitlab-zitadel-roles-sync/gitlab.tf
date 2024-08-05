data "gitlab_users" "all_users" {
}

data "gitlab_groups" "iac" {
  search = "iac"
}

data "gitlab_group_membership" "iac" {
  group_id = data.gitlab_groups.iac.id
}

resource "gitlab_group_membership" "admin_iac_update" {
  for_each     = local.need_to_update_admin_users
  group_id     = data.gitlab_groups.iac.id
  user_id      = each.value.user_id
  access_level = "maintainer"
}

resource "gitlab_group_membership" "non_admin_iac_update" {
  for_each     = local.need_to_update_non_admin_users
  group_id     = data.gitlab_groups.iac.id
  user_id      = each.value.user_id
  access_level = "developer"
}

data "zitadel_user_grants" "active" {
  project_name = "gitlab"
}

resource "gitlab_user" "zitadel_users" {
  for_each         = local.need_to_add_users
  name             = each.value.name
  username         = each.value.username
  email            = each.key
  is_admin         = contains(each.value.user_grant.role_keys, "gitlab_administrators")
  can_create_group = true
  is_external      = false
  reset_password   = false
}


resource "gitlab_group_membership" "iac_add" {
  for_each     = gitlab_user.zitadel_users
  group_id     = data.gitlab_groups.iac.id
  user_id      = each.key
  access_level = each.value.is_admin ? "maintainer" : "developer"
}

locals {
  admin_users                    = { for user_grant in data.zitadel_user_grants.active : user_grant.email => user_grant if contains(user_grant.role_keys, "gitlab_administrators") }
  non_admin_users                = { for user_grant in data.zitadel_user_grants.active : user_grant.email => user_grant if contains(user_grant.role_keys, "gitlab_users") }
  gitlab_admin_users             = { for gitlab_user in data.gitlab_users.all_users : gitlab_user.email => gitlab_user if gitlab_user.is_admin }
  gitlab_non_admin_users         = { for gitlab_user in data.gitlab_users.all_users : gitlab_user.email => gitlab_user if !gitlab_user.is_admin }
  all_gitlab_users               = { for gitlab_user in data.gitlab_users.all_users : gitlab_user.email => gitlab_user }
  need_to_update_admin_users     = { for key, user in local.gitlab_admin_users : key => user if !contains(local.admin_users.keys, key) }
  need_to_update_non_admin_users = { for key, user in local.gitlab_non_admin_users : key => user if !contains(local.non_admin_users.keys, key) }
  need_to_add_users              = { for user_grant in data.zitadel_user_grants.active : user_grant.email => user_grant if !contains(local.all_gitlab_users.keys, user_grant.email) }
}
