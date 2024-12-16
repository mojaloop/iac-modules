skip = true

generate "required_providers" {
  path = "required_providers.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {
  required_version = "${local.common_vars.tf_version}"

  required_providers {
    local = {
      source = "hashicorp/local"
      version = "${local.common_vars.local_tf_provider_version}"
    }
  }
}

EOF
}

locals {
  common_vars = yamldecode(file("${get_env("CONFIG_PATH")}/common-vars.yaml"))
}