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

variable "gitlab_project_url" {
  type        = string
  description = "gitlab_project_url"
}

variable "nat_public_ips" {
  type        = list(any)
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

variable "storage_class_name" {
  type        = string
  description = "storage_class_name"
  default     = "longhorn"
}

variable "gitlab_readonly_group_name" {
  type        = string
  description = "gitlab_readonly_group_name"
}

variable "gitlab_admin_group_name" {
  type        = string
  description = "gitlab_admin_group_name"
}


variable "external_secret_sync_wave" {
  type        = string
  description = "external_secret_sync_wave"
  default     = "-11"
}

variable "properties_key_map" {
  type        = map(any)
  description = "contains keys for known properties"
}

variable "secrets_key_map" {
  type        = map(any)
  description = "contains keys for known secrets"
}

variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}

variable "dns_provider" {
  description = "provider for ext dns"
}

variable "minio_loki_user" {
  description = "minio username for loki"
}

variable "minio_loki_bucket" {
  description = "minio bucket name for loki"
}

variable "minio_longhorn_user" {
  description = "minio username for longhorn"
}

variable "minio_longhorn_bucket" {
  description = "minio bucket name for longhorn"
}

variable "minio_api_url" {
  description = "Url for minio api access"
}

locals {
  cloud_region                                     = data.gitlab_project_variable.cloud_region.value
  k8s_cluster_type                                 = data.gitlab_project_variable.k8s_cluster_type.value
  cloud_platform                                   = data.gitlab_project_variable.cloud_platform.value
  longhorn_backups_bucket_name                     = data.gitlab_project_variable.longhorn_backups_bucket_name.value
  cert_manager_credentials_client_id_name          = data.gitlab_project_variable.cert_manager_credentials_client_id_name.value
  cert_manager_credentials_client_secret_name      = data.gitlab_project_variable.cert_manager_credentials_client_secret_name.value
  external_dns_credentials_client_secret_name      = data.gitlab_project_variable.external_dns_credentials_client_secret_name.value
  external_dns_credentials_client_id_name          = data.gitlab_project_variable.external_dns_credentials_client_id_name.value
  cert_manager_credentials_secret_provider_key     = var.secrets_key_map["external_dns_cred_secret_key"]
  cert_manager_credentials_id_provider_key         = var.secrets_key_map["external_dns_cred_id_key"]
  external_dns_credentials_secret_provider_key     = var.secrets_key_map["external_dns_cred_secret_key"]
  external_dns_credentials_id_provider_key         = var.secrets_key_map["external_dns_cred_id_key"]
  longhorn_backups_credentials_secret_provider_key = var.secrets_key_map["longhorn_backups_cred_secret_key"]
  longhorn_backups_credentials_id_provider_key     = var.secrets_key_map["longhorn_backups_cred_id_key"]
}
