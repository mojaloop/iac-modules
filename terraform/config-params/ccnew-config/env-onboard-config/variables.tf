variable "grafana_fqdn" {
  description = "fqdn for grafana"
}

variable "env_name" {
  description = "name of environment"
}

variable "vault_fqdn" {
  description = "fqdn for vault"
}

variable "argocd_fqdn" {
  description = "fqdn for vault"
}

variable "kv_path" {
  description = "key value secret path"
}

variable "user_rbac_group" {
  type        = string
  description = "rbac group in idm for user access via netbird"
}
