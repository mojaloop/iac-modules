resource "aws_iam_user" "ebs_csi_user" {
  name = "${local.base_name}-AmazonEBSCSIUser"
}

resource "aws_iam_user_policy_attachment" "ebs_csi_policy_attachment" {
  user       = aws_iam_user.ebs_csi_user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_access_key" "ebs_csi_access_key" {
  user = aws_iam_user.ebs_csi_user.name
}

resource "vault_kv_secret_v2" "ebs_csi_credentials" {
  mount               = var.kv_path
  name                = "${var.env_name}/loki_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode({
    aws_access_key = aws_iam_access_key.ebs_csi_access_key.id
    aws_secret_key = aws_iam_access_key.ebs_csi_access_key.secret
  })
}


locals {
  base_name = "${var.cc_cluster_name}.${var.env_name}"
} 
