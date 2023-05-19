variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "output_dir" {
  default     = "../apps"
  type        = string
  description = "where to output files"
}

variable "gitlab_server_url" {
  type        = string
  description = "gitlab_server_url"
}

variable "vault_oauth_client_id" {
  type = string
  default = ""
  description = "vault_oauth_client_id"
}

variable "vault_oauth_client_secret" {
  type = string
  default = ""
  description = "vault_oauth_client_secret"
  sensitive = true
}

variable "gitlab_project_url" {
  type        = string
  description = "gitlab_project_url"
}

variable "stateful_resources_config_file" {
  default     = "../config/stateful-resources.json"
  type        = string
  description = "where to pull stateful resources config"
}

variable "stateful_resources_namespace" {
  type        = string
  description = "stateful_resources_namespace"
  default     = "stateful_resources"
}

variable "nat_public_ips" {
  type        = string
  description = "nat_public_ips"
}
variable "internal_load_balancer_dns" {
  type        = string
  description = "internal_load_balancer_dns"
}
variable "external_load_balancer_dns" {
  type        = string
  description = "external_load_balancer_dns"
}
variable "private_subdomain" {
  type        = string
  description = "private_subdomain"
}
variable "public_subdomain" {
  type        = string
  description = "public_subdomain"
}

variable "current_gitlab_project_id" {
  type        = string
  description = "current_gitlab_project_id"
}

variable "gitlab_group_name" {
  type        = string
  description = "gitlab_group_name"
}

variable "gitlab_api_url" {
  type        = string
  description = "gitlab_api_url"
}

variable "gitops_project_path_prefix" {
  type        = string
  description = "gitops_project_path_prefix"
  default     = "infra"
}

## certmanager    

variable "cert_manager_chart_repo" {
  type        = string
  description = "cert_manager_chart_repo"
  default     = "https://charts.jetstack.io"
}
variable "cert_manager_chart_version" {
  type        = string
  description = "1.11.0"
}

variable "cert_manager_namespace" {
  type        = string
  description = "cert_manager_namespace"
  default     = "certmanager"
}

variable "cert_manager_credentials_secret" {
  type        = string
  description = "cert_manager_credentials_secret"
  default     = "route53-cert-man-credentials"
}

variable "cert_manager_issuer_sync_wave" {
  type        = string
  description = "cert_manager_issuer_sync_wave"
  default     = "-7"
}

variable "letsencrypt_server" {
  type        = string
  description = "letsencrypt_server"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "letsencrypt_email" {
  type        = string
  description = "letsencrypt_email"
  default     = "cicd@example.com"
}

## external secrets
variable "external_secret_sync_wave" {
  type        = string
  description = "external_secret_sync_wave"
  default     = "-11"
}

##consul

variable "consul_chart_repo" {
  type        = string
  description = "consul_chart_repo"
  default     = "https://helm.releases.hashicorp.com"
}

variable "consul_chart_version" {
  type        = string
  description = "consul_chart_version"
  default     = "1.0.3"
}

variable "consul_replicas" {
  type        = string
  description = "consul_replicas"
  default     = "1"
}

variable "consul_storage_size" {
  type        = string
  description = "storage_size"
  default     = "3Gi"
}

variable "consul_namespace" {
  type        = string
  description = "consul_namespace"
  default     = "consul"
}

##longhorn/storage

variable "longhorn_chart_repo" {
  type        = string
  description = "longhorn_chart_repo"
  default     = "https://charts.longhorn.io"
}

variable "longhorn_chart_version" {
  type        = string
  description = "longhorn_chart_version"
  default     = "1.4.0"
}

variable "longhorn_credentials_secret" {
  type        = string
  description = "longhorn_credentials_secret"
  default     = "longhorn-s3-credentials"
}

variable "longhorn_backups_bucket_name" {
  type        = string
  description = "longhorn_backups_bucket_name"
}

variable "longhorn_reclaim_policy" {
  type        = string
  description = "longhorn_reclaim_policy"
  default     = "Retain"
}

variable "longhorn_replica_count" {
  type        = string
  description = "longhorn_replica_count"
  default     = "1"
}

variable "longhorn_namespace" {
  type        = string
  description = "longhorn_namespace"
  default     = "longhorn-system"
}

variable "gitlab_key_longhorn_backups_access_key" {
  type        = string
  description = "gitlab_key_longhorn_backups_access_key"
}

variable "gitlab_key_longhorn_backups_secret_key" {
  type        = string
  description = "gitlab_key_longhorn_backups_secret_key"
}

variable "longhorn_job_sync_wave" {
  type        = string
  description = "longhorn_job_sync_wave"
  default     = "-9"
}

variable "storage_class_name" {
  type        = string
  description = "storage_class_name"
  default     = "longhorn"
}


## external-dns

variable "external_dns_credentials_secret" {
  type        = string
  description = "external_dns_credentials_secret"
  default     = "route53-external-dns-credentials"
}

variable "gitlab_key_route53_external_dns_access_key" {
  type        = string
  description = "gitlab_key_route53_external_dns_access_key"
}

variable "gitlab_key_route53_external_dns_secret_key" {
  type        = string
  description = "gitlab_key_route53_external_dns_secret_key"
}

variable "external_dns_chart_repo" {
  type        = string
  description = "external_dns_chart_repo"
  default     = "https://charts.bitnami.com/bitnami"
}

variable "external_dns_chart_version" {
  type        = string
  description = "external_dns_chart_version"
  default     = "6.7.2"
}

variable "external_dns_namespace" {
  type        = string
  description = "external_dns_namespace"
  default     = "external-dns"
}

variable "dns_cloud_region" {
  type = string
  description = "cloud region for ext dns"
}
## vault

variable "vault_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-5"
}

variable "vault_namespace" {
  type        = string
  description = "vault_namespace"
  default     = "vault"
}

variable "vault_config_operator_namespace" {
  type        = string
  description = "vault_config_operator_namespace"
  default     = "vault-config"
}

variable "vault_config_operator_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-5"
}

variable "vault_cm_sync_wave" {
  type        = string
  description = "vault_sync_wave"
  default     = "-6"
}

variable "vault_chart_repo" {
  type        = string
  description = "vault_chart_repo"
  default     = "https://helm.releases.hashicorp.com"
}
variable "vault_chart_version" {
  type        = string
  description = "vault_chart_version"
  default     = "0.23.0"
}
variable "vault_config_operator_helm_chart_repo" {
  type        = string
  description = "vault_config_operator_helm_chart_repo"
  default     = "https://redhat-cop.github.io/vault-config-operator"
}
variable "vault_config_operator_helm_chart_version" {
  type        = string
  description = "vault_config_operator_helm_chart_version"
  default     = "0.8.9"
}
variable "gitlab_key_vault_iam_user_access_key" {
  type        = string
  description = "gitlab_key_vault_iam_user_access_key"
}
variable "gitlab_key_vault_iam_user_secret_key" {
  type        = string
  description = "gitlab_key_vault_iam_user_secret_key"
}
variable "vault_kms_seal_kms_key_id" {
  type        = string
  description = "vault_kms_seal_kms_key_id"
}

variable "vault_gitlab_credentials_secret" {
  type = string
  description = "vault_gitlab_credentials_secret"
  default = "vault-gitlab-credentials-secret"
}

variable "vault_seal_credentials_secret" {
  type = string
  description = "vault_seal_credentials_secret"
  default = "vault-seal-credentials-secret"
}

variable "vault_ingress_internal_lb" {
  type        = bool
  description = "vault_ingress_class"
  default     = true
}
variable "vault_k8s_auth_path" {
  type        = string
  description = "vault_k8s_auth_path"
  default     = "auth/kubernetes"
}

variable "enable_vault_oidc" {
  type = bool
  default = false
}

variable "gitlab_readonly_group_name" {
  type        = string
  description = "gitlab_readonly_group_name"
}

variable "gitlab_admin_group_name" {
  type        = string
  description = "gitlab_admin_group_name"
}

## nginx


variable "nginx_helm_chart_repo" {
  type        = string
  description = "nginx_helm_chart_repo"
  default     = "https://kubernetes.github.io/ingress-nginx"
}
variable "nginx_helm_chart_version" {
  type        = string
  description = "nginx_helm_chart_version"
  default     = "4.3.0"
}
variable "nginx_external_namespace" {
  type        = string
  description = "nginx_external_namespace"
  default     = "nginx-ext"
}
variable "nginx_internal_namespace" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "ingress_sync_wave" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "default_ssl_certificate" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "wildcare_certificate_wave" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "internal_ingress_class_name" {
  type        = string
  description = "nginx_internal_namespace"
  default     = "nginx-int"
}
variable "external_ingress_class_name" {
  type        = string
  description = "external_ingress_class_name"
  default     = "nginx-ext"
}
variable "internal_ingress_https_port" {
  type        = number
  description = "internal_ingress_https_port"
  default     = 31443
}
variable "internal_ingress_http_port" {
  type        = number
  description = "internal_ingress_http_port"
  default     = 31080
}
variable "external_ingress_https_port" {
  type        = number
  description = "external_ingress_https_port"
  default     = 32443
}
variable "external_ingress_http_port" {
  type        = number
  description = "external_ingress_http_port"
  default     = 32080
}

variable "gitlab_key_gitlab_ci_pat" {
  type        = string
  description = "gitlab_key_gitlab_ci_pat"
}

locals {
  cloud_region     = data.gitlab_project_variable.cloud_region.value
  k8s_cluster_type = data.gitlab_project_variable.k8s_cluster_type.value
  cloud_platform   = data.gitlab_project_variable.cloud_platform.value
}
