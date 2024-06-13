data "zitadel_orgs" "default" {
  state = "ORG_STATE_ACTIVE"
}

data "zitadel_org" "default" {
  for_each = toset(data.zitadel_orgs.default.ids)
  id       = each.value
}

output "org_names" {
  value = toset([
    for org in data.zitadel_org.default : org.name
  ])
}

output "org_ids" {
  value = toset([
    for org in data.zitadel_org.default : org.id
  ])
}
