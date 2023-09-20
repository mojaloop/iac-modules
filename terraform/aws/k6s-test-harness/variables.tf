variable "cluster_name" {
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

variable "ami_id" {
  description = "ami for docker server"
}

variable "vpc_cidr" {
  description = "CIDR Subnet to use for the VPC"
}

variable "vpc_id" {
  description = "vpc id for security group"
}

variable "subnet_id" {
  description = "subnet to place docker server"
}

variable "key_pair_name" {
  description = "key_pair_name for docker server"
}

variable "os_user_name" {
  default     = "ubuntu"
  type        = string
  description = "os username for bastion host"
}

variable "delete_storage_on_term" {
  description = "delete_storage_on_term"
  type        = bool
  default     = false
}

variable "k6s_listening_ports" {
  type        = list
  default     = ["5050", "5000", "6060", "25001", "25002", "25003", "25004", "25005", "25006", "25007", "25008", "9999", "9090", "9080"]
  description = "which ports to listen for k6s"
}

variable "docker_server_instance_type" {
  type        = string
  default     = "m5.2xlarge"
  description = "vm size for docker server"
}

variable "docker_server_root_vol_size" {
  type        = number
  default     = 40
  description = "root vol size for docker server"
}

variable "docker_server_extra_vol_size" {
  type        = number
  default     = 100
  description = "extra vol size for docker server"
}

variable "public_zone_id" {
  description = "zone id to add dns record"
}

variable "test_harness_hostname" {
  description = "hostname to add to dns"
  default     = "test-harness"
}

variable "docker_compose_version" {
  default = "2.20.3"
}

locals {
  name             = var.cluster_name
  base_domain      = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  identifying_tags = { Cluster = var.cluster_name, Domain = local.base_domain }
  common_tags      = merge(local.identifying_tags, var.tags)
}
