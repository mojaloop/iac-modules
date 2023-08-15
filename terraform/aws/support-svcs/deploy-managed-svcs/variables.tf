###
# Required variables without default values
###
variable "support_service_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
}

variable "vpc_cidr" {
  default     = "10.26.0.0/22"
  type        = string
  description = "CIDR Subnet to use for the VPC, will be split into multiple /24s for the required private and public subnets"
}

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of azs"
}


variable "block_size" {
  type = number
  default = 3
}

variable "mysql_enabled" {
  type = bool
  default = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = false
}

variable "managed_services_config_file" {
  description = "location of json config file for databases to create"
}

###
# Local copies of variables to allow for parsing
###
locals {
  support_service_name = var.support_service_name
  identifying_tags = { vpc = local.support_service_name}
  common_tags = merge(local.identifying_tags, var.tags)
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets_list  = [for az in local.azs : "public-${az}"]
  private_subnets_list = [for az in local.azs : "private-${az}"]
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  managed_services = jsondecode(file(var.managed_services_config_file))
  rds_services = { for managed_service in local.managed_services : managed_service.resource_name => managed_service if managed_service.external_service && managed_service.resource_type == "mysql"}
}