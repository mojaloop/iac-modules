variable "zone_id" {
  type = string
  description = "route53 zone id"
}

variable "name" {
  type = string
  description = "unique name for deployment"
}

variable "domain" {
  type = string
  description = "domain name for deployment"
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}
variable "days_retain_gitlab_snapshot" {
  type        = number
  description = "number of days to retain gitlab snapshots"
  default     = 7
}