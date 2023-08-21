###
# Required variables without default values
###
variable "deployment_name" {
  description = "Deployment name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
}

variable "managed_services_config_file" {
  description = "location of json config file for databases to create"
}

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of azs"
}

variable "os_user_name" {
  default     = "ubuntu"
  type        = string
  description = "os username for bastion host"
}

variable "vpc_cidr" {
  default     = "10.27.0.0/23"
  type        = string
  description = "CIDR Subnet to use for the VPC, will be split into multiple /24s for the required private and public subnets"
}

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name}
  common_tags = merge(local.identifying_tags, var.tags)
  managed_services = jsondecode(file(var.managed_services_config_file))
  #kafka_services =...
  external_services = { for managed_service in local.managed_services : managed_service.resource_name => managed_service if managed_service.external_service}
  rds_services = { for managed_service in local.managed_services : managed_service.resource_name => managed_service if managed_service.external_service && managed_service.resource_type == "mysql"}
}