output "id" {
  description = "ID of the AMI"
  value       = data.aws_ami.ubuntu.id
}
