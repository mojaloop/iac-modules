#!/bin/bash
cat <<'EOT' >terragrunt.hcl
skip = true
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    config_path      = "${get_env("KUBECONFIG_LOCATION")}"
    namespace        = "${get_env("K8S_STATE_NAMESPACE")}"
  }
}
EOF
}
EOT

source setlocalvars.sh
export output_dir=$(terragrunt run-all --terragrunt-exclude-dir k8s-deploy/ output ansible_output_dir | tr -d '"')
source $output_dir/gitlabenv.sh
export KUBECONFIG_LOCATION=$output_dir/kubeconfig
export K8S_STATE_NAMESPACE=gitlab
terragrunt run-all init -migrate-state -force-copy
rm -rf /tmp/bootstrap || true
git config --global user.email "root@{{ gitlab_fqdn }}"
git config --global user.name "root"
git clone https://root:${gitlab_access_token}@${gitlab_fqdn}/iac/bootstrap.git /tmp/bootstrap
cp -rf ansible-k8s-deploy/ default-config/ k8s-deplooy/ *.sh terragrunt.hcl ../gitlab/ci-templates/bootstrap-v2/. /tmp/bootstrap
cd /tmp/bootstrap
git add .
git commit -m "Push bootstrap files to GitLab"
git push
