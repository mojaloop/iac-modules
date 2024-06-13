data "zitadel_orgs" "default" {
  state = "ORG_STATE_ACTIVE"
}

output "org_names" {
  value = toset([
    for org in data.zitadel_org.default : org.name
  ])
}
