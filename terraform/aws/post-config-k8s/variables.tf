###
# Required variables without default values
###
variable "name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "domain" {
  description = "Base domain to attach the cluster to."
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}

variable "public_zone_id" {
  type        = string
  description = "public_zone_id"
}

variable "private_zone_id" {
  type        = string
  description = "private_zone_id"
}

variable "iac_group_name" {
  type        = string
  description = "iac group name"
  default     = "admin"
}

variable "create_iam_user" {
  type        = bool
  description = "create iam user for ci"
  default     = false
}

variable "create_ext_dns_user" {
  type        = bool
  description = "create iam user for ext dns"
  default     = true
}

variable "backup_bucket_name" {
  type        = string
  description = "bucket name for backups"
  default     = "velero"
}

variable "backup_enabled" {
  type        = bool
  description = "create backup policies and bucket in s3"
  default     = false
}

variable "backup_bucket_force_destroy" {
  type        = bool
  description = "auto delete s3 bucket content"
  default     = false
}

###
# Local copies of variables to allow for parsing
###
locals {
  base_domain = "${replace(var.name, "-", "")}.${var.domain}"
}
