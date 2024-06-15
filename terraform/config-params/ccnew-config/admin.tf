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

resource "zitadel_human_user" "admin" {
  org_id             = local.org_id
  user_name          = "rootauto@zitadel.${var.zitadel_fqdn}"
  first_name         = "root"
  last_name          = "admin"
  nick_name          = "admin"
  display_name       = "admin"
  preferred_language = "en"
  gender             = "GENDER_MALE"
  phone              = "+41799999999"
  is_phone_verified  = true
  email              = "test@zitadel.com"
  is_email_verified  = true
  initial_password   = "#Password1!"
}

resource "zitadel_instance_member" "admin" {
  user_id = zitadel_human_user.admin.id
  roles   = ["IAM_OWNER"]
}

resource "zitadel_org_member" "admin" {
  org_id  = local.org_id
  user_id = zitadel_human_user.admin.id
  roles   = ["ORG_OWNER"]
}

