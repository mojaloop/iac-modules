# TODO: add var.deployment_name in the name

# Create IAM Policy for CloudWatch Metrics Read Access
resource "aws_iam_policy" "cloudwatch_readonly" {
  name        = "${var.deployment_name}-cloudwatch-readonly"
  description = "Policy for reading CloudWatch data"

  # Policy sources
  # https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/
  # https://github.com/prometheus-community/yet-another-cloudwatch-exporter?tab=readme-ov-file#authentication
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowReadingMetricsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingTagsInstancesRegionsFromEC2",
        "Effect" : "Allow",
        "Action" : ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingResourcesForTags",
        "Effect" : "Allow",
        "Action" : "tag:GetResources",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingResourceMetricsFromPerformanceInsights",
        "Effect" : "Allow",
        "Action" : "pi:GetResourceMetrics", # needed for RDS and documentdb metrics 
        "Resource" : "*"
      }
    ]
  })

}

# Create IAM Role
resource "aws_iam_role" "cloudwatch_readonly" {
  name = "${var.deployment_name}-cloudwatch-readonly"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          AWS = aws_iam_user.cloudwatch_readonly.arn
        }
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "cloudwatch_readonly" {
  policy_arn = aws_iam_policy.cloudwatch_readonly.arn
  role       = aws_iam_role.cloudwatch_readonly.name
}

# Create IAM User
resource "aws_iam_user" "cloudwatch_readonly" {
  name = "${var.deployment_name}-cloudwatch-readonly-user"
}

# Attach Role to User via inline policy
resource "aws_iam_user_policy" "cloudwatch_readonly" {
  name = "${var.deployment_name}-cloudwatch-readonly-user-role-access"
  user = aws_iam_user.cloudwatch_readonly.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.cloudwatch_readonly.arn
      }
    ]
  })
}

# Generate Access Keys for the User
resource "aws_iam_access_key" "cloudwatch_readonly" {
  user = aws_iam_user.cloudwatch_readonly.name
}
