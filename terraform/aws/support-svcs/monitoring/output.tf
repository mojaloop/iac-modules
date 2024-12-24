
output "secrets_var_map" {
  sensitive = true
  value = {
    # cloudwatch_access_key_id : aws_iam_access_key.cloudwatch_readonly.id,
    "${var.cloudwatch_access_id_name}" : aws_iam_access_key.cloudwatch_readonly.id,
    "${var.cloudwatch_access_secret_name}" : aws_iam_access_key.cloudwatch_readonly.secret,
  }
}

output "properties_var_map" {
  value = {
    cloudwatch_role_arn = aws_iam_role.cloudwatch_readonly.arn
  }
}

output "secrets_key_map" {
  value = {
    "${var.cloudwatch_access_id_name}" : "${var.cloudwatch_access_id_name}",
    "${var.cloudwatch_access_secret_name}" : "${var.cloudwatch_access_secret_name}",
  }
}



# resource "null_resource" "print_dictionary" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "Printing output secrets_key_map"
#       echo '${jsonencode(secrets_key_map)}' | jq '.'
#     EOT
#   }
# }