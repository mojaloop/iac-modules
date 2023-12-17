variable "app_var_map" {
  type = any
  default = {}
}

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

variable "vpc_cidr" {
  default     = "10.106.0.0/23"
  type        = string
  description = "CIDR Subnet to use for the VPC, will be split into multiple /24s for the required private and public subnets"
}

variable "master_node_count" {
  type        = number
  default     = 1
  description = "Number of master nodes to deploy"
}

variable "master_instance_type" {
  type    = string
  default = "m5.large"
}

variable "agent_node_count" {
  type        = number
  default     = 3
  description = "Number of agent nodes to deploy"
}
variable "agent_instance_type" {
  type    = string
  default = "m5.large"
}

variable "longhorn_backup_object_store_destroy" {
  description = "destroy object store backup on destroy of env"
  type        = bool
  default     = false
}


variable "kubeapi_port" {
  type        = number
  description = "kubeapi_port"
  default     = 6443
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


variable "master_node_supports_traffic" {
  type        = bool
  default     = false
  description = "whether or not to enable ingress traffic on master nodes"
}

variable "dns_provider" {
  type = string
  default = "aws"
  description = "which dns provider to use, defaults to cloud provider"
}

variable "node_pools" {
  type = any
}
