variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
  type        = string
}
variable "oidc_provider_group_claim_prefix" {
  type        = string
  description = "zitadel:grants"
}
