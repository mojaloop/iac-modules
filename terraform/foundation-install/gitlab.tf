/* data "gitlab_project_variable" "terraform_infra_templates_url" {
  project = var.current_gitlab_project_id
  key     = "TERRAFORM_INFRA_TEMPLATES_URL"
}

data "gitlab_project_variable" "terraform_apps_templates_url" {
  project = var.current_gitlab_project_id
  key     = "TERRAFORM_APPS_TEMPLATES_URL"
} */

data "gitlab_project_variable" "k8s_cluster_type" {
  project = var.current_gitlab_project_id
  key     = "K8S_CLUSTER_TYPE"
}

data "gitlab_project_variable" "cloud_platform" {
  project = var.current_gitlab_project_id
  key     = "CLOUD_PLATFORM"
}

data "gitlab_project_variable" "cloud_region" {
  project = var.current_gitlab_project_id
  key     = "CLOUD_REGION"
}

data "gitlab_group_variable" "gitlab_ci_pat" {
  group = data.gitlab_group.iac.id
  key   = var.gitlab_key_gitlab_ci_pat
}

data "gitlab_group" "iac" {
  full_path = var.gitlab_group_name
}