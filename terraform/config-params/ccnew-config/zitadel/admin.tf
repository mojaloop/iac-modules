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

resource "zitadel_action" "flat_roles" {
  org_id          = local.org_id
  name            = "flatRoles"
  allowed_to_fail = true
  timeout         = "10s"
  script          = <<EOF
    function flatRoles(ctx, api) {
      if (ctx.v1.user.grants == undefined || ctx.v1.user.grants.count == 0) {
        return;
      }

      let grants = [];
      ctx.v1.user.grants.grants.forEach(claim => {
        claim.roles.forEach(role => {
            grants.push(claim.projectId+':'+role)  
        })
      })

      api.v1.claims.setClaim('my:zitadel:grants', grants)
    }
  EOF
}

resource "zitadel_trigger_actions" "flat_roles_preuserinfo_creation" {
  org_id       = local.org_id
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
  action_ids   = [zitadel_action.flat_roles.id]
}

resource "zitadel_trigger_actions" "flat_roles_preaccesstoken_creation" {
  org_id       = local.org_id
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION"
  action_ids   = [zitadel_action.flat_roles.id]
}
