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
resource "aws_iam_user" "route53_external_dns" {
  count = var.create_ext_dns_user ? 1 : 0
  name  = "${local.base_domain}-external-dns"
  tags  = merge({ Name = "${local.base_domain}-route53-external-dns" }, var.tags)
}
resource "aws_iam_access_key" "route53_external_dns" {
  count = var.create_ext_dns_user ? 1 : 0
  user  = aws_iam_user.route53_external_dns[0].name
}

resource "aws_iam_user_policy_attachment" "route53_external_dns" {
  count      = var.create_ext_dns_user ? 1 : 0
  user       = aws_iam_user.route53_external_dns[0].name
  policy_arn = aws_iam_policy.route53_external_dns.arn
}
# IAM Policy to allow external-dns user to update the given zone and cert-manager to create validation records
resource "aws_iam_policy" "route53_external_dns" {
  name = "${local.base_domain}-external-dns"

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


resource "aws_iam_role" "external_dns_cicd" {
  count = var.create_ext_dns_role ? 1 : 0
  name  = "${local.base_domain}-external-dns-cicd"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.ci_iam_user[0].arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = merge({ Name = "${local.base_domain}-external-dns-cicd" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ext_dns_assume_role" {
  count      = var.create_ext_dns_role ? 1 : 0
  role       = aws_iam_role.external_dns_cicd[0].name
  policy_arn = aws_iam_policy.route53_external_dns.arn
}

resource "aws_iam_policy" "object_storage" {
  count = var.backup_enabled ? 1 : 0
  name  = "${local.base_domain}-object_storage"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:PutObjectTagging",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${var.backup_bucket_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.backup_bucket_name}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "object_storage" {
  count = var.backup_enabled ? 1 : 0
  name  = "${var.backup_bucket_name}-object-storage"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.ci_iam_user[0].arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = merge({ Name = "${var.backup_bucket_name}-object-storage" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "object_storage_assume_role" {
  count      = var.backup_enabled ? 1 : 0
  role       = aws_iam_role.object_storage[0].name
  policy_arn = aws_iam_policy.object_storage[0].arn
}

resource "aws_s3_bucket" "backup_bucket" {
  count         = var.backup_enabled ? 1 : 0
  bucket        = var.backup_bucket_name
  force_destroy = var.backup_bucket_force_destroy
  tags          = merge({ Name = var.backup_bucket_name }, var.tags)
}

# EBS CSI driver
resource "aws_iam_role" "csi_role" {
  name  = "${local.base_domain}-csi"
  count = var.create_csi_role ? 1 : 0
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
tags = merge({ Name = "${local.base_domain}-csi-role" }, var.tags)
}

# Attach the managed policy for EBS CSI Driver
resource "aws_iam_role_policy_attachment" "csi_policy" {
  count = var.create_csi_role ? 1 : 0
  role       = aws_iam_role.csi_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create an instance profile for the IAM Role
resource "aws_iam_instance_profile" "csi_instance_profile" {
  count = var.create_csi_role ? 1 : 0
  name  = "${local.base_domain}-csi-instance-profile"
  role = aws_iam_role.csi_role[0].name
}