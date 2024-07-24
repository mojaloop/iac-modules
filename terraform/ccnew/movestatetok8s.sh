cat <<'EOT' >terragrunt.hcl
skip = true
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    config_path      = "${KUBECONFIG_LOCATION}"
    namespace        = "${K8S_STATE_NAMESPACE}"
  }
}
EOF
}
EOT

terragrunt run-all init -migrate-state -force-copy
