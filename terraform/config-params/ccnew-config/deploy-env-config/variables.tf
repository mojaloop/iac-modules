
variable "kv_path" {
  description = "path for kv engine"
  default     = "secret"
}

variable "nexus_fqdn" {
  description = "fqdn for nexus"
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

variable "env_token_ttl" {
  type        = string
  description = "time to live for the env token"
}

variable "obj_store_region" {
  description = "cloud region"
}