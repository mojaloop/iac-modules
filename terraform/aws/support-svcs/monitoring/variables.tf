variable "deployment_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
  default     = "dev"
}


# TODO: re-evaluate if we need to parametrize the access id/key variable names
variable "cloudwatch_access_id_name" {
  description = "Name of cloudwatch access id"
  default     = "cloudwatch_access_key_id"
}

variable "cloudwatch_access_secret_name" {
  description = "Name of cloudwatch secret key"
  default     = "cloudwatch_access_secret_key"
}
