###
# Required variables without default values
###
variable "support_service_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
  default = ""
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
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

variable "netmaker_ami" {
  description = "ami for netmaker"
  default = "none for enable_netmaker false"
}

variable "block_size" {
  type = number
  default = 3
}

variable "enable_netmaker" {
  type = bool
  default = false
}

variable "netmaker_vpc_cidr" {
  type = string
  default = "10.27.0.0/24"
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

variable "databases" {
  description = "Specifies database parameters"

  type =  map(object({
    db_name = string
    engine = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    storage_encrypted = bool
    multi_az = bool
    skip_final_snapshot = bool
    username = string
    port = string
    maintenance_window = string
    backup_window = string
    monitoring_interval = string
    family = string
    major_engine_version = string
    deletion_protection = bool
    parameters = list(object({
      name = string
      value = string
    }))
    options = list(object({
      option_name = string
      option_settings = list(object({
        name = string
        value = string
      })) 
    }))

    tags = map(string)
    
  }))

  default = {}
}

###
# Local copies of variables to allow for parsing
###
locals {
  support_service_name = "${var.support_service_name}-orcr"
  identifying_tags = { vpc = local.support_service_name}
  common_tags = merge(local.identifying_tags, var.tags)
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets_list  = [for az in local.azs : "public-${az}"]
  private_subnets_list = [for az in local.azs : "private-${az}"]
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  databases = var.databases
}