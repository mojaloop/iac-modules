#!/bin/bash
set -e
source externalrunner.sh
source scripts/setlocalvars.sh
terragrunt run-all init -upgrade
cat <<'EOT' >terragrunt.hcl
skip = true
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}

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
EOT
terragrunt run-all init -migrate-state -force-copy