resource "aws_kms_key" "vault_unseal_key" {
  description             = "KMS Key used to auto-unseal vault"
  deletion_window_in_days = 10
}

resource "aws_iam_user" "vault_unseal" {
  name = "${var.name}-vault-unseal"
  tags = merge({ Name = "${var.name}-vault_unseal" }, var.tags)
}
resource "aws_iam_access_key" "vault_unseal" {
  user = aws_iam_user.vault_unseal.name
}
# IAM Policy to allow longhorn store objects
resource "aws_iam_user_policy" "vault_unseal_kms" {
  name = "${var.name}-vault-unseal-kms"
  user = aws_iam_user.vault_unseal.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VaultUnsealerEncryptDecryptKms",
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:DescribeKey"
            ],
            "Resource": [
                "arn:aws:kms:*:*:key/${aws_kms_key.vault_unseal_key.key_id}"
            ]
        }
    ]
}
EOF
}
