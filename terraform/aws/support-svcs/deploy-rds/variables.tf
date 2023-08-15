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

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name}
  common_tags = merge(local.identifying_tags, var.tags)
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets_list  = [for az in local.azs : "public-${az}"]
  private_subnets_list = [for az in local.azs : "private-${az}"]
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
}