resource "vault_aws_secret_backend" "aws" {
  path                      = var.backend_path
  access_key                = data.vault_generic_secret.access_key
  secret_key                = data.vault_generic_secret.secret_key
  region                    = var.region
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
}

resource "vault_aws_secret_backend_role" "dns_access" {
  backend         = vault_aws_secret_backend.aws.path
  name            = var.dns_access_role
  credential_type = "iam_user"
  policy_arns     = [var.ext_dns_cloud_policy]
}

data "vault_generic_secret" "access_key" {
  path = "${var.kv_path}/${var.access_key_path}"
}
data "vault_generic_secret" "secret_key" {
  path = "${var.kv_path}/${var.secret_key_path}"
}
