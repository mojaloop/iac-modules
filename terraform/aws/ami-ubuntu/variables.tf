variable "most_recent" {
  description = "boolean, maps to `most_recent` parameter for `aws_ami` data source"
  type        = bool
  default     = true
}

variable "name_map" {
  description = "map of release numbers to names, including trusty, xenial, zesty, and artful"
  type        = map(string)
  default = {
    "20.04" = "focal"
    "19.10" = "eoan"
    "19.04" = "disco"
    "18.04" = "bionic"
    "17.10" = "artful"
    "17.04" = "zesty"
    "16.04" = "xenial"
    "14.04" = "trusty"
  }
}

variable "release" {
  description = "default ubuntu release to target"
  type        = string
  default     = "20.04"
}
