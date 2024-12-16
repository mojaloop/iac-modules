variable "deployment_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of existing Security Groups to be allowed to connect to the DocumentDB cluster"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to be allowed to connect to the DocumentDB cluster"
}


variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  default     = ""
}

variable "mongodb_services" {
  description = "mongodb services to create"
}

variable "private_subnets" {

}

variable "vpc_id" {
    
}