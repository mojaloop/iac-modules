

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

#can't do for each over sensitve var, break out keys in separate map
variable "secrets_key_map" {
  type = map
  description = "keys for secrets to set in vault"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "gitlab_project_id" {
  description = "gitlab_project_id"
}

variable "platform_stateful_resources_config_file" {
  type = string
}

variable "managed_stateful_resources_config_file" {
  type = string
}

variable "db_mediated_by_control_center" {
  type        = bool
  default     = false
}

variable "monolith_managed_stateful_resources_config_file" {
  type = string
}
