

resource "aws_iam_instance_profile" "gitlab" {
  name = "${replace(var.domain, ".", "-")}-${var.cluster_name}-gitlab"
  role = aws_iam_role.gitlab.name
}

resource "aws_iam_role" "gitlab" {
  name = "${replace(var.domain, ".", "-")}-${var.cluster_name}-gitlab"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.gitlab.json
}

data "aws_iam_policy_document" "gitlab" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_user" "gitlab_ci_iam_user" {
  name = "${var.cluster_name}-gitlab-ci"
  tags = merge({ Name = "${local.name}-gitlab-ci" }, local.common_tags)
}

resource "aws_iam_access_key" "gitlab_ci_iam_user_key" {
  user    = aws_iam_user.gitlab_ci_iam_user.name
}

resource "aws_iam_user_group_membership" "iac_group" {
  user = aws_iam_user.gitlab_ci_iam_user.name
  groups = [
    var.iac_group_name
  ]
}