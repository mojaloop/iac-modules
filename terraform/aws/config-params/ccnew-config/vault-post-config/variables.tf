variable "cert_manager_cloud_policy" {
  description = "policy arn for cert man"
}
variable "external_dns_cloud_role" {
  description = "role arn for dns"
}
variable "object_storage_cloud_role" {
  description = "role arn for object storage"
}
variable "dns_backend_path" {
  description = "auth path for cloud engine"
  default     = "cc-cloud-provider-dns"
}
variable "dns_access_role" {
  description = "role name dns"
}
variable "cert_manager_access_role" {
  description = "role name for cert man since it doesn't support session token"
}
variable "object_storage_backend_path" {
  description = "auth path for cloud engine for object storage"
  default     = "cc-cloud-provider-os"
}
variable "object_storage_access_role" {
  description = "role name object storage"
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
variable "enable_object_storage_backend" {
  description = "enable object storage vault backend"
  default     = false
}
variable "enable_dns_backend" {
  description = "enable dns vault backend"
  default     = false
}
