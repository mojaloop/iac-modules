module "ses" {
  source  = "cloudposse/ses/aws"
  version = "~> 0.22.0"

  domain                 = var.domain
  iam_access_key_max_age = 0
  name                   = "${var.name}-ses"
  ses_group_enabled      = false
  ses_user_enabled       = true
  verify_dkim            = true
  verify_domain          = true
  zone_id                = var.zone_id

  tags = merge({}, var.tags)
}