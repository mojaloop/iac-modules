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
  type = string
  description = "public_zone_id"
}

variable "private_zone_id" {
  type = string
  description = "private_zone_id"
}

variable "longhorn_backup_s3_destroy" {
  description = "destroy s3 backup on destroy of env"
  type        = bool
  default     = false
}

###
# Local copies of variables to allow for parsing
###
locals {
  base_domain     = "${replace(var.name, "-", "")}.${var.domain}"
}