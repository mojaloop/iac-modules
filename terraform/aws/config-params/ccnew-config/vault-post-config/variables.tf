variable "cert_manager_cloud_policy" {
  description = "policy arn for cert man"
}
<<<<<<< HEAD
variable "external_dns_cloud_role" {
  description = "role arn for dns"
}
variable "object_storage_cloud_role" {
  description = "role arn for object storage"
}
variable "dns_backend_path" {
=======
variable "backend_path" {
>>>>>>> main
  description = "auth path for cloud engine"
  default     = "cc-cloud-provider"
}
variable "dns_access_role" {
<<<<<<< HEAD
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
=======
  description = "role hame dns"
>>>>>>> main
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
