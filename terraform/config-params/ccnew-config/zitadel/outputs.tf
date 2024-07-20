output "zitadel_admin_human_user_id" {
  value = zitadel_human_user.admin.id
}
# needed since there currently is no lookup for user except by id
