#!/bin/bash
set -e
source setlocalvars.sh
export output_dir=$ANSIBLE_BASE_OUTPUT_DIR/k8s-deploy
source $output_dir/gitlabenv.sh
export KUBECONFIG_LOCATION=$output_dir/kubeconfig
export K8S_STATE_NAMESPACE=gitlab

cat <<'EOT' >terragrunt.hcl
skip = true
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix    = "${replace(path_relative_to_include(), "/", "-")}-state"
    config_path      = "${get_env("KUBECONFIG_LOCATION")}"
    namespace        = "${get_env("K8S_STATE_NAMESPACE")}"
  }
}
EOF
}
EOT

terragrunt run-all init -migrate-state -force-copy
rm -rf /tmp/bootstrap || true
git config --global user.email "root@{{ gitlab_fqdn }}"
git config --global user.name "root"
git clone https://root:${gitlab_access_token}@${gitlab_fqdn}/iac/bootstrap.git /tmp/bootstrap
mkdir -p /tmp/bootstrap/ansible-k8s-deploy /tmp/bootstrap/k8s-deploy
cp -rf ansible-k8s-deploy/terragrunt.hcl /tmp/bootstrap/ansible-k8s-deploy/
cp -rf default-config /tmp/bootstrap
cp -rf k8s-deploy/terragrunt.hcl /tmp/bootstrap/k8s-deploy/
cp -rf *.sh terragrunt.hcl /tmp/bootstrap
cp -rf ../gitlab/ci-templates/bootstrap-v2/. /tmp/bootstrap
cd /tmp/bootstrap
git add .
git commit -m "Push bootstrap files to GitLab"
git push