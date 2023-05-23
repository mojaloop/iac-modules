/**
 * # AMI ID Finder for Ubuntu Images
 *
 * Use this module to find the AMI ID for the version of Ubuntu for your Availability Zone.
 *
 */

data "aws_partition" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = var.most_recent

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.name_map[var.release]}-${var.release}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [data.aws_partition.current.partition == "aws-us-gov" ? "513442679011" : "099720109477"] # Canonical
}
