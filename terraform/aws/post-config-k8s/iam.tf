resource "aws_iam_user" "ci_iam_user" {
  count = var.create_iam_user ? 1 : 0
  name  = "${local.base_domain}-ci"
  tags  = merge({ Name = "${local.base_domain}-ci" }, var.tags)
}

resource "aws_iam_access_key" "ci_iam_user_key" {
  count = var.create_iam_user ? 1 : 0
  user  = aws_iam_user.ci_iam_user[0].name
}

resource "aws_iam_user_group_membership" "iac_group" {
  count = var.create_iam_user ? 1 : 0
  user  = aws_iam_user.ci_iam_user[0].name
  groups = [
    var.iac_group_name
  ]
}
# IAM user with permissions to be able to update route53 records, for use with external-dns
resource "aws_iam_user" "route53-external-dns" {
  count = var.create_ext_dns_user ? 1 : 0
  name  = "${local.base_domain}-external-dns"
  tags  = merge({ Name = "${local.base_domain}-route53-external-dns" }, var.tags)
}
resource "aws_iam_access_key" "route53-external-dns" {
  count = var.create_ext_dns_user ? 1 : 0
  user  = aws_iam_user.route53-external-dns[0].name
}
# IAM Policy to allow external-dns user to update the given zone and cert-manager to create validation records
resource "aws_iam_user_policy" "route53-external-dns" {
  count = var.create_ext_dns_user ? 1 : 0
  name  = "${local.base_domain}-external-dns"
  user  = aws_iam_user.route53-external-dns[0].name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.public_zone_id}",
        "arn:aws:route53:::hostedzone/${var.private_zone_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [ 
        "route53:GetChange"
      ],
      "Resource": [ 
        "arn:aws:route53:::change/*" 
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListHostedZonesByName"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
