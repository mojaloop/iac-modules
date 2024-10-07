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