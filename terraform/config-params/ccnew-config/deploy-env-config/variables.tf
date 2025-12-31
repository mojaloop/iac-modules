
variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}

variable "nexus_fqdn" {
  description = "fqdn for nexus"
}

variable "registry_mirror_fqdn" {
  description = "fqdn for registry mirror"
}

variable "zitadel_fqdn" {
  description = "fqdn for zitadel"
}

variable "environment_list" {
  description = "env repos to pre-create"
}


variable "nexus_docker_repo_listening_port" {
  description = "listening port for nexus"
  default     = 443
}

variable "obj_store_gw_fqdn" {
  description = "fqdn for object storage gw"
}

variable "obj_store_regional_endpoint" {
  description = "regional endpoint for object storage gw"
}

variable "obj_store_gw_port" {
  description = "port for object storage gw"
  default     = 443
}

variable "object_storage_path_style" {
  description = "path style for object storage"
}

variable "object_store_insecure_connection" {
  description = "insecure connection for object storage"
}

variable "object_store_insecure_skip_verify" {
  description = "skip tls verify for object storage"
  default     = false
}

variable "tenant_vault_listening_port" {
  description = "port for vault"
  default     = 443
}


variable "namespace" {
  description = "namespace to create the buckets"
  default     = "gitlab"
}

variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
  default     = "tenant-admins"
}

variable "gitlab_readonly_rbac_group" {
  type        = string
  description = "rbac group in gitlab for readonly access via oidc"
  default     = "tenant-viewers"
}

variable "netbird_api_host" {
  description = "fqdn for netbird"
}

variable "netbird_version" {
  description = "netbird version"
}

variable "netbird_client_version" {
  description = "netbird client version"
}

variable "argocd_namespace" {
  description = "argocd ns"
}

variable "kubernetes_oidc_groups_claim" {
  description = "value to use for oidc k8s group claim"
}

variable "mimir_gw_fqdn" {
  description = "fqdn for mimir gateway"
}

variable "cc_cidr_block" {
  description = "cidr block that cc is running in"
}

variable "sc_cidr_block" {
  description = "cidr block that sc is running in"
}

variable "sc_cloud_provider" {
  description = "cloud provider that sc is running in"
}

variable "env_token_ttl" {
  type        = string
  description = "time to live for the env token"
}

variable "obj_store_region" {
  description = "cloud region"
}

variable "monitoring_domain" {
  description = "domain for monitoring apps"
}

variable "cc_domain" {
  description = "domain that cc is running in"
}

variable "sc_domain" {
  description = "Domain for the sc endpoints"
  type        = string
}

variable "nexus_readonly_username" {
  description = "readonly username for nexus"
}

variable "registry_mirror_readonly_username" {
  description = "readonly username for registry mirror"
}

variable "sc_api_host" {
  type        = string
  description = "Host for the SC API server"
  default     = "localhost"
}

variable "sc_api_port" {
  type        = number
  description = "Port for the SC API server"
  default     = 6443
}

variable "helm_oci_proxy_repos" {
  description = "OCI proxy repositories for helm, comma separated"
  type        = string
  default     = ""
}
variable "helm_classic_proxy_repos" {
  description = "Classic proxy repositories for helm, comma separated"
  type        = string
  default     = ""
}
variable "classic_helm_repo_base_url" {
  description = "base url for helm classic proxy repo"
  type        = string
}
variable "oci_helm_repo_base_url" {
  description = "base url for helm oci proxy repo"
  type        = string
}

locals {
  helm_classic_proxy_repos_string = join(",", [
    for item in split(",", var.helm_classic_proxy_repos) : 
    "${split("=", item)[1]}=${var.classic_helm_repo_base_url}/${split("=", item)[0]}/"
    if length(trim(item, " ")) > 0
  ])
  
  helm_oci_proxy_repos_string = join(",", [
    for item in split(",", var.helm_oci_proxy_repos) : 
    "${split("=", item)[1]}=${var.oci_helm_repo_base_url}/${split("=", item)[0]}"
    if length(trim(item, " ")) > 0
  ])
}