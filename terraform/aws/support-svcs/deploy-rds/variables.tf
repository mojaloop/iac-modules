###
# Required variables without default values
###
variable "deployment_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
}

variable "rds_services" {
  description = "rds services to create"
}

variable "security_group_id" {
  description = "which security group to attach rds to"
}

variable "private_subnets" {
  description = "which private subnets to attach rds to"
}

variable "block_size" {
  type = number
  default = 3
}

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name}
  common_tags = merge(local.identifying_tags, var.tags)
}