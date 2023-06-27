

variable "kv_path" {
  description = "path for kv engine"
  default = "secret"
}

variable "properties_var_map" {
  type = map
  description = "properties to set in gitlab"
}

variable "secrets_var_map" {
  type = map
  sensitive = true
  description = "secrets to set in vault"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "gitlab_project_id" {
  description = "gitlab_project_id"
}