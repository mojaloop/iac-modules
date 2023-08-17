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

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name}
  common_tags = merge(local.identifying_tags, var.tags)
  managed_services = jsondecode(file(var.managed_services_config_file))
  rds_services = { for managed_service in local.managed_services : managed_service.resource_name => managed_service if managed_service.external_service && managed_service.resource_type == "mysql"}
}