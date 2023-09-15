output "test_harness_private_ip" {
  description = "ip to connect to test harness"
  value       = aws_instance.docker_server.private_ip
}


output "var_map" {
  value = {
    k6s_listening_port          = var.k6s_listening_port
    docker_extra_volume_name    = "docker-extra"
    docker_extra_vol_mount      = true
    docker_extra_ebs_volume_id  = aws_instance.docker_server.ebs_block_device.*.volume_id[0]
    docker_extra_volume_size_mb = aws_instance.docker_server.ebs_block_device.*.volume_size[0] * 1074
  }
}
