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

variable "zitadel_server_url" {
  type        = string
  description = "zitadel_server_url"
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
  default     = "block-storage-sc"
}

variable "gitlab_readonly_group_name" {
  type        = string
  description = "gitlab_readonly_group_name"
}

variable "gitlab_admin_group_name" {
  type        = string
  description = "gitlab_admin_group_name"
}

variable "vault_admin_rbac_group" {
  type        = string
  description = "vault_admin_rbac_group"
}

variable "vault_readonly_rbac_group" {
  type        = string
  description = "vault_readonly_rbac_group"
}

variable "zitadel_project_id" {
  type        = string
  description = "zitadel_project_id"
}

variable "grafana_admin_rbac_group" {
  type        = string
  description = "grafana_admin_rbac_group"
}

variable "grafana_user_rbac_group" {
  type        = string
  description = "grafana_admin_rbac_group"
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

variable "object_store_api_url" {
  type        = string
  description = "object_store_api_url"
}

variable "object_store_regional_endpoint"{
  type        = string
  description = "object_store_regional_endpoint"
}

variable "object_storage_path_style" {
  type        = bool
  description = "object_storage_path_style"
}

variable "object_store_insecure_connection" {
  type        = bool
  description = "object_store_insecure_connection"
}

variable "central_observability_endpoint" {
  type        = string
  description = "central observability endpoint (mimir api)"
}

variable "default_ssl_certificate" {
  type        = string
  description = "default_ssl_certificate"
  default     = "lets-enc-external-tls"
}

variable "default_internal_ssl_certificate" {
  type        = string
  description = "default_internal_ssl_certificate"
  default     = "lets-enc-internal-tls"
}

variable "managed_db_host" {
  type        = string
  description = "url to managed db based on haproxy"
}

variable "managed_svc_as_monolith" {
  type        = bool
  default     = false
}

variable "db_mediated_by_control_center" {
  type        = bool
  default     = false
}

variable "cc_name" {
  type        = string
  description = "The name of the control center."
}

variable "cloud_region" {
  type        = string
  description = "The AWS region where resources will be deployed."
}

variable "database_subnets" {
  type        = string
  description = "A list of subnet IDs to deploy the database instances into."
}

variable "availability_zones" {
  type        = string
  description = "A list of availability zones for the database instances."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be deployed."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC."
}
locals {
  cloud_region                                     = data.gitlab_project_variable.cloud_region.value
  k8s_cluster_type                                 = data.gitlab_project_variable.k8s_cluster_type.value
  cloud_platform                                   = data.gitlab_project_variable.cloud_platform.value
  cert_manager_credentials_client_id_name          = data.gitlab_project_variable.cert_manager_credentials_client_id_name.value
  cert_manager_credentials_client_secret_name      = data.gitlab_project_variable.cert_manager_credentials_client_secret_name.value
  external_dns_credentials_client_secret_name      = data.gitlab_project_variable.external_dns_credentials_client_secret_name.value
  external_dns_credentials_client_id_name          = data.gitlab_project_variable.external_dns_credentials_client_id_name.value
  cert_manager_credentials_secret_provider_key     = var.secrets_key_map["external_dns_cred_secret_key"]
  cert_manager_credentials_id_provider_key         = var.secrets_key_map["external_dns_cred_id_key"]
  external_dns_credentials_secret_provider_key     = var.secrets_key_map["external_dns_cred_secret_key"]
  external_dns_credentials_id_provider_key         = var.secrets_key_map["external_dns_cred_id_key"]
  longhorn_backups_credentials_secret_provider_key = "longhorn_backup_bucket_secret_key_id"
  longhorn_backups_credentials_id_provider_key     = "longhorn_backup_bucket_access_key_id"
  loki_bucket                                      = data.gitlab_project_variable.loki_bucket.value
  tempo_bucket                                     = data.gitlab_project_variable.tempo_bucket.value
}
