output "acme_iam_access_id" {
  value = aws_iam_access_key.route53_acme.id
}

output "acme_iam_secret_key" {
  value = aws_iam_access_key.route53_acme.secret
  sensitive = true
}