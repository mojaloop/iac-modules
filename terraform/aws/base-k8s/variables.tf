###
# Required variables without default values
###
variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "domain" {
  description = "Base domain to attach the cluster to."
  type        = string
}

variable "ext_interop_switch_subdomain" {
  description = "subdomain for interop ext"
  default     = "ext"
}

variable "int_interop_switch_subdomain" {
  description = "subdomain for interop int"
  default     = "int"
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  default     = "10.106.0.0/23"
  type        = string
  description = "CIDR Subnet to use for the VPC, will be split into multiple /24s for the required private and public subnets"
}

variable "block_size" {
  default     = 3
  description = "block size of individual subnets"
}

variable "create_public_zone" {
  default     = true
  type        = bool
  description = "Whether to create public zone in route53. true or false, default true"
}

variable "create_private_zone" {
  default     = true
  type        = bool
  description = "Whether to create private zone in route53. true or false, default true"
}

variable "manage_parent_domain" {
  default     = true
  type        = bool
  description = "Whether to manage parent domain in terraform, default true"
}

variable "manage_parent_domain_ns" {
  default     = true
  type        = bool
  description = "Whether to manage parent domain ns record in terraform, default true"
}

variable "node_pools" {
  type = any
}

variable "az_count" {
  type        = number
  default     = 3 #debug
  description = "Number of azs"
}

variable "dns_zone_force_destroy" {
  description = "destroy public zone on destroy of env"
  type        = bool
  default     = false
}

variable "os_user_name" {
  default     = "ubuntu"
  type        = string
  description = "os username for bastion host"
}

variable "kubeapi_port" {
  type        = number
  description = "kubeapi_port"
  default     = 6443
}

variable "wireguard_port" {
  type        = number
  description = "wireguard_port"
  default     = 31821
}
variable "target_group_internal_https_port" {
  type        = number
  description = "target_group_internal_https_port"
  default     = 31443
}
variable "target_group_internal_http_port" {
  type        = number
  description = "target_group_internal_http_port"
  default     = 31080
}

variable "target_group_internal_health_port" {
  type        = number
  description = "target_group_internal_health_port"
  default     = 31081
}

variable "target_group_external_https_port" {
  type        = number
  description = "target_group_external_https_port"
  default     = 32443

}
variable "target_group_external_http_port" {
  type        = number
  description = "target_group_external_http_port"
  default     = 32080
}

variable "target_group_external_health_port" {
  type        = number
  description = "target_group_external_health_port"
  default     = 32081

}

variable "enable_k6s_test_harness" {
  type        = bool
  default     = false
  description = "whether or not to enable creation of vm for k6s"
}

variable "k6s_docker_server_instance_type" {
  type        = string
  default     = "m5.2xlarge"
  description = "vm instance type for k6s"
}

variable "k6s_docker_server_fqdn" {
  type        = string
  default     = "test-harness"
  description = "fqdn for k6s test harness vm"
}

variable "master_node_supports_traffic" {
  type        = bool
  default     = false
  description = "whether or not to enable ingress traffic on master nodes"
}

variable "dns_provider" {
  type        = string
  default     = "aws"
  description = "which dns provider to use, defaults to cloud provider"
}

variable "dns_resolver_ip" {
  default     = "1.1.1.1"
  description = "which dns host to use"
}

variable "create_ci_iam_user" {
  type        = bool
  description = "create iam user for ci"
  default     = false
}
variable "create_ext_dns_user" {
  type        = bool
  description = "create iam user for dns"
  default     = true
}
variable "create_ext_dns_role" {
  type        = bool
  description = "create iam role for ext dns"
  default     = false
}
variable "iac_group_name" {
  type        = string
  description = "iac group name"
  default     = "admin"
}

variable "create_haproxy_dns_record" {
  type        = bool
  description = "whether to create public dns record for private ip of bastion for haproxy"
  default     = false
}

variable "backup_bucket_name" {
  type        = string
  description = "backup"
  default     = "velero"
}

variable "backup_enabled" {
  type        = bool
  default     = false
  description = "enable backup bucket and policies"
}

variable "create_csi_role" {
  type        = bool
  description = "create ebs role and policies for EBS CSI"
  default     = false
}

variable "backup_bucket_force_destroy" {
  type        = bool
  description = "auto delete s3 bucket content"
  default     = false
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

variable "coredns_bind_address" {
  type        = string
  description = "link-local address (part of the 169.254.0.0/16 range) and is reserved for communication within the node itself or between nodes in the local network"
  default     = "169.254.20.10"
}

###
# Local copies of variables to allow for parsing
###
locals {
  name             = var.cluster_name
  base_domain      = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  identifying_tags = { Cluster = var.cluster_name, Domain = local.base_domain }
  common_tags      = merge(local.identifying_tags, var.tags)
  ssh_keys         = [] # This has been replaced with a dynamically generated key, but could be extended to allow passing additional ssh keys if needed
}
