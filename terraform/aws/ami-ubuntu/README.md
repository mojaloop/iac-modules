# AMI ID Finder for Ubuntu Images

Use this module to find the AMI ID for the version of Ubuntu for your Availability Zone.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| aws | ~> 3.23 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.23 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| most\_recent | boolean, maps to `most_recent` parameter for `aws_ami` data source | `bool` | `true` | no |
| name\_map | map of release numbers to names, including trusty, xenial, zesty, and artful | `map(string)` | <pre>{<br>  "14.04": "trusty",<br>  "16.04": "xenial",<br>  "17.04": "zesty",<br>  "17.10": "artful",<br>  "18.04": "bionic",<br>  "19.04": "disco",<br>  "19.10": "eoan",<br>  "20.04": "focal"<br>}</pre> | no |
| release | default ubuntu release to target | `string` | `"20.04"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the AMI |

