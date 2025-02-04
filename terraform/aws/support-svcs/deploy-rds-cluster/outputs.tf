output "db_instance_master_user_password" {
 value = random_password.rds_master_password.result
}

output "db_instance_address" {
  value = aws_rds_cluster.rds_cluster[0].endpoint
}

output "master_username" {
  value = aws_rds_cluster.rds_cluster[0].master_username
}