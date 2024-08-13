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
  description = "path for tenant kv engine"
  default     = "secret"
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
variable "nginx_jwt_namespace" {
  type        = string
  description = "nginx_jwt_namespace"
  default     = "nginx-jwt"
}

variable "istio_internal_gateway_name" {
  type        = string
  description = "istio_internal_gateway_name"
}

variable "istio_external_gateway_name" {
  type        = string
  description = "istio_external_gateway_name"
}

variable "istio_internal_wildcard_gateway_name" {
  type        = string
  description = "istio_internal_wildcard_gateway_name"
}

variable "istio_external_wildcard_gateway_name" {
  type        = string
  description = "istio_external_wildcard_gateway_name"
}

variable "istio_create_ingress_gateways" {
  type        = bool
  description = "should istio create ingress gateways"
  default     = true
}

variable "istio_internal_gateway_namespace" {
  type        = string
  description = "istio_internal_gateway_namespace"
  default     = "istio-ingress-int"
}

variable "istio_external_gateway_namespace" {
  type        = string
  description = "istio_external_gateway_namespace"
  default     = "istio-ingress-ext"
}

variable "opentelemetry_enabled" {
  type        = bool
  description = "bool that enables opentelemetry in cluster"
  default     = false
} 

variable "opentelemetry_namespace_filtering" {
  type        = bool
  description = "bool that enables tracing by namespace"
  default     = false
}

variable "cert_manager_service_account_name" {
  type        = string
  description = "cert_manager_service_account_name"
}

variable "vault_namespace" {
  type        = string
  description = "vault_namespace"
}
variable "cert_manager_namespace" {
  type        = string
  description = "cert_manager_namespace"
}
variable "vault_certman_secretname" {
  description = "secret name to create for tls offloading via certmanager"
  type        = string
  default     = "vault-tls-cert"
}
