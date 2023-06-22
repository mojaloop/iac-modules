export IAC_TERRAFORM_MODULES_TAG=v0.9.79
export IAC_TEMPLATES_TAG=$IAC_TERRAFORM_MODULES_TAG
export CONTROL_CENTER_CLOUD_PROVIDER=aws
export ANSIBLE_BASE_OUTPUT_DIR=/tmp/output
export PRIVATE_REPO_TOKEN=nullvalue
export PRIVATE_REPO_USER=nullvalue
export PRIVATE_REPO=example.com
export AWS_PROFILE=oss

terragrunt run-all destroy --terragrunt-non-interactive
