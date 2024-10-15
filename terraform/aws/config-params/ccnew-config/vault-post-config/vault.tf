resource "vault_aws_secret_backend" "aws_object_storage" {
  count                     = local.enable_object_storage_backend ? 1 : 0
  path                      = var.object_storage_backend_path
  access_key                = data.vault_generic_secret.credentials.data[var.access_key_name]
  secret_key                = data.vault_generic_secret.credentials.data[var.secret_key_name]
  region                    = var.region
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
}

resource "vault_aws_secret_backend_role" "object_storage" {
  count           = local.enable_object_storage_backend ? 1 : 0
  backend         = vault_aws_secret_backend.aws_object_storage[0].path
  name            = var.object_storage_access_role
  credential_type = "assumed_role"
  role_arns       = [var.object_storage_cloud_role]
}


resource "vault_aws_secret_backend" "aws_dns" {
  count                     = local.enable_dns_backend ? 1 : 0
  path                      = var.dns_backend_path
  access_key                = data.vault_generic_secret.credentials.data[var.access_key_name]
  secret_key                = data.vault_generic_secret.credentials.data[var.secret_key_name]
  region                    = var.region
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
}

resource "vault_aws_secret_backend_role" "dns_access" {
  count           = local.enable_dns_backend ? 1 : 0
  backend         = vault_aws_secret_backend.aws_dns[0].path
  name            = var.dns_access_role
  credential_type = "assumed_role"
  role_arns       = [var.external_dns_cloud_role]
}

data "vault_generic_secret" "credentials" {
  path = "${var.kv_path}/${var.credential_path}"
}

locals {
  enable_object_storage_backend = tobool(var.enable_object_storage_backend)
  enable_dns_backend            = tobool(var.enable_dns_backend)
}
