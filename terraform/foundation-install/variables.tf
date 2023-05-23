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


variable "gitlab_key_gitlab_ci_pat" {
  type        = string
  description = "gitlab_key_gitlab_ci_pat"
}

variable "external_secret_sync_wave" {
  type        = string
  description = "external_secret_sync_wave"
  default     = "-11"
}

locals {
  cloud_region     = data.gitlab_project_variable.cloud_region.value
  k8s_cluster_type = data.gitlab_project_variable.k8s_cluster_type.value
  cloud_platform   = data.gitlab_project_variable.cloud_platform.value
}
