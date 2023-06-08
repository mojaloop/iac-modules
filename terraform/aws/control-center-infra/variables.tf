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
  default     = "10.25.0.0/22"
  type        = string
  description = "CIDR Subnet to use for the VPC"
}

variable "create_public_zone" {
  default = true
  type = bool
  description = "Whether to create public zone in route53. true or false, default true"
}

variable "create_private_zone" {
  default = true
  type = bool
  description = "Whether to create private zone in route53. true or false, default true"
}

variable "route53_zone_force_destroy" {
  description = "destroy public zone on destroy of env"
  type        = bool
  default     = false
}

variable "az_count" {
  type        = number
  default     = 1
  description = "Number of azs"
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

variable "enable_github_oauth" {
  type = bool
  description = "enable auth from github oauth app"
  default = false
}

variable "github_oauth_id" {
  type        = string
  description = "github oauth id"
  default = ""
}

variable "github_oauth_secret" {
  type        = string
  description = "github oauth secret"
  default = ""
  sensitive = true
}

variable "smtp_server_enable" {
  type = bool
  description = "enable smtp server (ses)"
  default = false
}

variable "smtp_server_address" {
  type        = string
  description = "smtp_server_address"
  default = ""
}

variable "smtp_server_port" {
  type        = number
  description = "smtp_server_port"
  default = 587
}

variable "smtp_server_user" {
  type        = string
  description = "smtp_server_user"
  default = ""
}

variable "smtp_server_pw" {
  type        = string
  description = "smtp_server_pw"
  default = ""
  sensitive = true
}

variable "smtp_server_mail_domain" {
  type        = string
  description = "smtp_server_mail_domain"
  default = ""
}

variable "acme_api_endpoint" {
  type = string
  description = "endpoint for acme certs"
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "nexus_docker_repo_listening_port" {
  type       = number
  default    = 8082
  description = "which port to listen for hosting docker repo on nexus"
}

variable "nexus_admin_listening_port" {
  type       = number
  default    = 8081
  description = "which port to listen for nexus admin"
}

variable "seaweedfs_s3_listening_port" {
  type       = number
  default    = 8333
  description = "which port to listen for seaweed s3"
}

variable "vault_listening_port" {
  type       = number
  default    = 8200
  description = "which port to listen for vault"
}

variable "days_retain_gitlab_snapshot" {
  type        = number
  description = "number of days to retain gitlab snapshots"
  default     = 7
}

variable "gitlab_instance_type" {
  type        = string
  default     = "m5.large"
  description = "vm size for gitlab server"
}

variable "docker_server_instance_type" {
  type        = string
  default     = "m5.2xlarge"
  description = "vm size for docker server"
}

variable "gitlab_server_root_vol_size" {
  type        = number
  default     = 40
  description = "root vol size for gitlab server"
}

variable "gitlab_server_extra_vol_size" {
  type        = number
  default     = 100
  description = "extra vol size for gitlab server"
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

variable "gitlab_version" {
  type        = string
  description = "gitlab_version"
  default = "15.11.0"
}

variable "gitlab_runner_version" {
  type        = string
  description = "gitlab_runner_version"
  default = "15.11.0"
}

variable "enable_netmaker" {
  type = bool
  default = true
  description = "enable creation of netmaker vpc/vm"
}

variable "netmaker_image_version" {
  type        = string
  description = "netmaker_image_version"
  default = "0.18.7"
}

variable "netmaker_control_network_name" {
  type        = string
  description = "control center netmaker network name"
  default = "cntrlctr"
}

variable "iac_group_name" {
  type        = string
  description = "iac group name"
  default     = "admin"
}

locals {
    name = var.cluster_name
    base_domain     = "${replace(var.cluster_name, "-", "")}.${var.domain}"
    identifying_tags = { Cluster = var.cluster_name, Domain = local.base_domain}
    common_tags = merge(local.identifying_tags, var.tags)
    nat_gatewway_cidr_blocks = [for ip in module.base_infra.nat_public_ips : "${ip}/32"]
}