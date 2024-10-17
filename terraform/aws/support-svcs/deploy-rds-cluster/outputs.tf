output "db_instance_master_user_secret_arn" {
  value = aws_rds_cluster.rds_cluster[0].master_user_secret[0].secret_arn
}

output "db_instance_address" {
  value = aws_rds_cluster.rds_cluster[0].endpoint
}