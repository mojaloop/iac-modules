
variable "ext_dns_cloud_policy" {
  description = "policy arn for dns"
}
variable "backend_path" {
  description = "auth path for cloud engine"
  default     = "cc-cloud-provider"
}
variable "dns_access_role" {
  description = "role hame dns"
}
variable "default_lease_ttl_seconds" {
  default = 3600
}
variable "region" {
  description = "cloud provider region"
}
variable "kv_path" {
  description = "path for kv2 engine"
}
variable "secret_key_name" {
  description = "key for secret key"
}

variable "access_key_name" {
  description = "key for access key"
}

variable "credential_path" {
  description = "path for credentials"
}
