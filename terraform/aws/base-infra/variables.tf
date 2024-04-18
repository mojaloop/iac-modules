###
# Required variables without default values
###
variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "domain" {
  description = "Domain to attach the cluster to."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  default     = "10.25.0.0/22"
  type        = string
  description = "CIDR Subnet to use for the VPC, will be split into multiple /24s for the required private and public subnets"
}

variable "configure_route_53" {
  type        = bool
  default     = true
  description = "whether route53 is to be configured at all or not"
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
  default     = false
  type        = bool
  description = "whether parent domain should be created and managed here"
}

variable "manage_parent_domain_ns" {
  default     = false
  type        = bool
  description = "whether ns record should be created for parent domain in that parent's zone that should already exist"
}

variable "az_count" {
  type        = number
  default     = 1
  description = "Number of azs"
}

variable "route53_zone_force_destroy" {
  description = "destroy public zone on destroy of env"
  type        = bool
  default     = false
}

variable "bastion_ami" {
  description = "ami for bastion"
}
variable "netmaker_ami" {
  description = "ami for netmaker"
  default     = "none for enable_netmaker false"
}

variable "block_size" {
  type    = number
  default = 3
}

variable "enable_netmaker" {
  type    = bool
  default = false
}

variable "netmaker_vpc_cidr" {
  type    = string
  default = "10.26.0.0/24"
}

variable "create_haproxy_dns_record" {
  default     = false
  type        = bool
  description = "whether to create public dns record for private ip of bastion for haproxy"
}

variable "private_subdomain_string" {
  type    = string
  default = "int"
}


###
# Local copies of variables to allow for parsing
###
locals {
  name                          = var.cluster_name
  cluster_domain                = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  cluster_parent_domain         = join(".", [for idx, part in split(".", local.cluster_domain) : part if idx > 0])
  cluster_parent_parent_domain  = join(".", [for idx, part in split(".", local.cluster_parent_domain) : part if idx > 0])
  identifying_tags              = { Cluster = var.cluster_name, Domain = local.cluster_domain }
  common_tags                   = merge(local.identifying_tags, var.tags)
  azs                           = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_zone                   = var.configure_route_53 ? (var.create_public_zone ? aws_route53_zone.public[0] : data.aws_route53_zone.public[0]) : null
  private_zone                  = var.configure_route_53 ? (var.create_private_zone ? aws_route53_zone.private[0] : data.aws_route53_zone.private[0]) : null
  cluster_parent_zone_id        = var.configure_route_53 ? (var.manage_parent_domain ? aws_route53_zone.cluster_parent[0].zone_id : data.aws_route53_zone.cluster_parent[0].zone_id) : null
  cluster_parent_parent_zone_id = var.configure_route_53 ? ((var.manage_parent_domain && var.manage_parent_domain_ns) ? data.aws_route53_zone.cluster_parent_parent[0].zone_id : null) : null
  ssh_keys                      = []
  public_subnets_list           = [for az in local.azs : "public-${az}"]
  private_subnets_list          = [for az in local.azs : "private-${az}"]
  subnet_list                   = flatten([for az in local.azs : concat(["private-${az}", "public-${az}"])])
  public_subnet_cidrs           = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs          = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
}
