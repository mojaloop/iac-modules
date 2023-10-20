# export GITLAB_URL=url
# export PROJECT_ID=projectid
# export TF_HTTP_USERNAME="root"
# export TF_STATE_BASE_ADDRESS="https://${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/terraform/state"
# export TF_HTTP_LOCK_METHOD="POST"
# export TF_HTTP_UNLOCK_METHOD="DELETE"
# export TF_HTTP_RETRY_WAIT_MIN="5"
# export TF_HTTP_PASSWORD=root-token
# export IAC_TERRAFORM_MODULES_TAG=v0.9.79
# export IAC_TEMPLATES_TAG=$IAC_TERRAFORM_MODULES_TAG
# export CONTROL_CENTER_CLOUD_PROVIDER=aws
# export ANSIBLE_BASE_OUTPUT_DIR=/tmp/output
# export PRIVATE_REPO_TOKEN=nullvalue
# export PRIVATE_REPO_USER=nullvalue
# export PRIVATE_REPO=example.com
# export AWS_PROFILE=oss
cd /iac-run-dir
source setenv
cd -
source setlocalenv.sh
source /tmp/archivedhttpstate.sh
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
      version = "${local.common_vars.local_provider_version}"
    }
  }
}
EOF
}

locals {
  common_vars = yamldecode(file("common-vars.yaml"))
  env_vars = yamldecode(file("environment.yaml"))
}
EOT
terragrunt run-all init -migrate-state -force-copy