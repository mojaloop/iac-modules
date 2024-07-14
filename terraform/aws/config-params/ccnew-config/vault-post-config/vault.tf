resource "vault_aws_secret_backend" "aws" {
  path                      = var.backend_path
  access_key                = data.vault_kv_secret_v2.access_key
  secret_key                = data.vault_kv_secret_v2.secret_key
  region                    = var.region
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
}

resource "vault_aws_secret_backend_role" "dns_access" {
  backend         = vault_aws_secret_backend.aws.path
  name            = var.dns_access_role
  credential_type = "iam_user"
  policy_arns     = [var.ext_dns_cloud_policy]
}


data "vault_kv_secret_v2" "access_key" {
  mount = var.kv_path
  name  = var.access_key_path
}

data "vault_kv_secret_v2" "secret_key" {
  mount = var.kv_path
  name  = var.secret_key_path
}
