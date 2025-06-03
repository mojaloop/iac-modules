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

variable "platform_stateful_resources_config_file" {
  type = string
}

variable "managed_stateful_resources_config_file" {
  type = string
}

variable "az_count" {
  type        = number
  default     = 3 # rds mutizone clsuter
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

variable "managed_svc_as_monolith"{
  default    = false 
  type       = bool
}

variable "monolith_managed_stateful_resources_config_file" {
  type = string
}

variable "bastion_instance_number" {
  type        = number
  description = "number of bastions to configure in asg"
  default     = 2
}

variable "bastion_instance_size" {
  type        = string
  description = "instance size of bastions to configure in asg"
  default     = "t3.small"
}

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name}
  common_tags = merge(local.identifying_tags, var.tags)
  
  st_res_managed_vars           = yamldecode(file(var.managed_stateful_resources_config_file))
  plt_st_res_config             = yamldecode(file(var.platform_stateful_resources_config_file))
  monolith_sts_res_vars        =  yamldecode(file(var.monolith_managed_stateful_resources_config_file))

  stateful_resources_config_vars_list = [local.st_res_managed_vars, local.plt_st_res_config]

  stateful_resources               = module.config_deepmerge.merged
  enabled_stateful_resources       = { for key, stateful_resource in local.stateful_resources : key => stateful_resource if stateful_resource.enabled }
  
  external_services = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" }
  rds_services      = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "mysql" }
  msk_services      = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "kafka" }
  mongodb_services  = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "mongodb" }  
  
  
  monolith_rds_services       = { for key, managed_resource in local.monolith_sts_res_vars : key => managed_resource } 
  monolith_internal_databases = var.managed_svc_as_monolith ? { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "mysql" } : {}

}
