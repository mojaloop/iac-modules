resource "gitlab_project_variable" "route53_external_dns_access_key" {
  project   = var.current_gitlab_project_id
  key       = "route53_external_dns_access_key"
  value     = aws_iam_access_key.route53-external-dns.id
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "route53_external_dns_secret_key" {
  project   = var.current_gitlab_project_id
  key       = "route53_external_dns_secret_key"
  value     = aws_iam_access_key.route53-external-dns.secret
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "longhorn_backups_access_key" {
  project   = var.current_gitlab_project_id
  key       = "longhorn_backups_access_key"
  value     = aws_iam_access_key.longhorn_backups.id
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "longhorn_backups_secret_key" {
  project   = var.current_gitlab_project_id
  key       = "longhorn_backups_secret_key"
  value     = aws_iam_access_key.longhorn_backups.secret
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "vault_iam_user_access_key" {
  project   = var.current_gitlab_project_id
  key       = "vault_iam_user_access_key"
  value     = aws_iam_access_key.vault_unseal.id
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "vault_iam_user_secret_key" {
  project   = var.current_gitlab_project_id
  key       = "vault_iam_user_secret_key"
  value     = aws_iam_access_key.vault_unseal.secret
  protected = false
  masked    = true
}

data "gitlab_project_variable" "k8s_cluster_type" {
  project   = var.current_gitlab_project_id
  key       = "K8S_CLUSTER_TYPE"
}

data "gitlab_project_variable" "cloud_region" {
  project   = var.current_gitlab_project_id
  key       = "CLOUD_REGION"
}

data "gitlab_project_variable" "netmaker_ops_token" {
  project   = var.current_gitlab_project_id
  key       = "NETMAKER_OPS_TOKEN"
}