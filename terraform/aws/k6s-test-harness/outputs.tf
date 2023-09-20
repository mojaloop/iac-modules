output "test_harness_private_ip" {
  description = "ip to connect to test harness"
  value       = aws_instance.docker_server.private_ip
}

output "test_harness_fqdn" {
  description = "fqdn to connect to test harness"
  value       = aws_route53_record.test_harness_private.fqdn
}

output "var_map" {
  value = {
    docker_extra_volume_name    = "docker-extra"
    docker_extra_vol_mount      = true
    docker_extra_ebs_volume_id  = aws_instance.docker_server.ebs_block_device.*.volume_id[0]
    docker_extra_volume_size_mb = aws_instance.docker_server.ebs_block_device.*.volume_size[0] * 1074
    k6s_callback_fqdn           = aws_route53_record.test_harness_private.fqdn
    docker_compose_version      = var.docker_compose_version
  }
}
