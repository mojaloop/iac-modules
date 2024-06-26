variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
}

variable "gitlab_readonly_rbac_group" {
  type        = string
  description = "rbac group in gitlab for readonly access via oidc"
}

variable "gitlab_hostname" {
  description = "gitlab hostname for oidc"
}

variable "vault_oauth_app_client_id" {
  description = "client id for gitlab oidc"
  sensitive = true
}
variable "vault_oauth_app_client_secret" {
  description = "client secret for gitlab oidc"
  sensitive = true
}
variable "vault_fqdn" {
  description = "vault_fqdn"
}

variable "kv_path" {
  description = "path for kv engine"
  default = "secret"
}

variable "env_map" {
  type = map
  description = "env repos to pre-create"
}

variable "iac_group_id" {
  description = "group to add env projects to"
}

variable "gitlab_runner_role_name" {
  description = "role name for gitlab runner"
  default = "gitlab-runner-role"
}

variable "gitlab_runner_jwt_path" {
  default = "gitlab_secrets_jwt"
  description = "vault jwt path for gitlab runner"
}

variable "gitlab_root_token" {
  description = "root token for gitlab for bootstrap only"
  sensitive = true
}

variable "vault_root_token" {
  description = "root token for tenancy vault for gitlabci only"
  sensitive = true
}

variable "netmaker_master_key" {
  description = "master key for netmaker"
  sensitive = true
}

variable "netmaker_host_name" {
  description = "netmaker host"
}

variable "netmaker_version" {
  description = "netmaker version"
}

variable "loki_data_expiry" {
  description = "number of days to expire minio loki bucket data"
  default = "7d"
}

variable "tempo_data_expiry_days" {
  description = "number of days to expire minio tempo bucket data"
  default = "7d"
}

variable "longhorn_backup_data_expiry" {
  description = "number of days to expire minio longhorn bucket data"
  default = "7d"
}

variable "velero_data_expiry" {
  description = "number of days to expire minio velero bucket data"
  default = "7d"
}

variable "percona_data_expiry" {
  description = "number of days to expire minio percona bucket data"
  default = "7d"
}

variable "private_subdomain_string" {
  description = "the string in the internal subdomain to distiguish with publci subdomain"
  default     = "internal"
}

variable "env_token_period" {
  description = "indicates that the token generated using this role should never expire. The token should be renewed within the duration specified by this value. At each renewal, the token's TTL will be set to the value of this field. Specified in seconds"
  default = "7776000"   # 90 days
}

variable "env_token_explicit_max_ttl" {
  description = "Tokens can have an explicit max TTL set on them. This value becomes a hard limit on the token's lifetime in seconds"
  default = "7776000"   # 90 days
}