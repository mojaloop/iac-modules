# IAM user with permissions to be able to update route53 records, for use with external-dns
resource "aws_iam_user" "route53_acme" {
  name = "${var.name}-acme"
  tags = merge({ Name = "${var.name}-route53-acme" }, var.tags)
}
resource "aws_iam_access_key" "route53_acme" {
  user = aws_iam_user.route53_acme.name
}
# IAM Policy to allow acme user to update the given zone and acme to create validation records
resource "aws_iam_user_policy" "route53_acme" {
  name = "${var.name}-acme"
  user = aws_iam_user.route53_acme.name

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