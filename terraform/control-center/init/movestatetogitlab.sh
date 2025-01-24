export BASE_DIR=$PWD
export TMP_GITLAB_DIR=/tmp/bootstrap
export TMP_TEMPLATE_DIR=/tmp/citemplates
rm -rf $TMP_GITLAB_DIR $TMP_TEMPLATE_DIR
export GITLAB_URL=$GITLAB_URL
export DOMAIN=$DOMAIN
export TF_HTTP_PASSWORD=$GITLAB_SERVER_TOKEN
cd control-center-pre-config
export PROJECT_ID=$PROJECT_ID
cd ..
export TF_HTTP_USERNAME="root"
export TF_STATE_BASE_ADDRESS="https://${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/terraform/state"
export TF_HTTP_LOCK_METHOD="POST"
export TF_HTTP_UNLOCK_METHOD="DELETE"
export TF_HTTP_RETRY_WAIT_MIN="5"
cat <<EOT >/tmp/archivedhttpstate.sh
export PRIVATE_REPO_USER=${PRIVATE_REPO_USER}
export PRIVATE_REPO_TOKEN=${PRIVATE_REPO_TOKEN}
export PRIVATE_REPO=${PRIVATE_REPO}
export AWS_PROFILE=${AWS_PROFILE}
export TF_HTTP_USERNAME=${TF_HTTP_USERNAME}
export PROJECT_ID=${PROJECT_ID}
export GITLAB_URL=${GITLAB_URL}
export TF_STATE_BASE_ADDRESS=${TF_STATE_BASE_ADDRESS}
export TF_HTTP_LOCK_METHOD=${TF_HTTP_LOCK_METHOD}
export TF_HTTP_UNLOCK_METHOD=${TF_HTTP_UNLOCK_METHOD}
export TF_HTTP_RETRY_WAIT_MIN=${TF_HTTP_RETRY_WAIT_MIN}
export TF_HTTP_PASSWORD=${TF_HTTP_PASSWORD}
export IAC_TEMPLATES_TAG=${IAC_TEMPLATES_TAG}
EOT
cat <<'EOT' >terragrunt.hcl
skip = true
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "http" {
    address        = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}"
    lock_address   = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}/lock"
    unlock_address = "${get_env("TF_STATE_BASE_ADDRESS")}/${path_relative_to_include()}/lock"
  }
}
EOF
}
EOT
terragrunt run-all init -migrate-state -force-copy
git clone https://${TF_HTTP_USERNAME}:${TF_HTTP_PASSWORD}@${GITLAB_URL}/iac/bootstrap.git $TMP_GITLAB_DIR
cd ${BASE_DIR}
cp -r README.md .gitignore setlocalenv.sh movestatetogitlab.sh movestatefromgitlab.sh sshkey  control-center-pre-config/ control-center-post-config/ ansible-cc-deploy/ ansible-cc-post-deploy/ environment.yaml terragrunt.hcl *-vars.yaml $TMP_GITLAB_DIR
git clone https://github.com/mojaloop/iac-modules.git $TMP_TEMPLATE_DIR
cd $TMP_TEMPLATE_DIR
git checkout $IAC_TEMPLATES_TAG
cp -r terraform/gitlab/ci-templates/bootstrap/. $TMP_GITLAB_DIR
cd $TMP_GITLAB_DIR
rm -rf control-center-pre-config/.te* control-center-post-config/.te* ansible-cc-deploy/.te* ansible-cc-post-deploy/.te*
rm -rf control-center-pre-config/terraform.tfstate* control-center-post-config/terraform.tfstate* ansible-cc-deploy/terraform.tfstate*  ansible-cc-post-deploy/terraform.tfstate*
git add .
git commit -m "Push existing bootstrap to GitLab"
git status
git push