resource "aws_instance" "docker_server" {
  ami                         = var.ami_id
  instance_type               = var.docker_server_instance_type
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.k6s_docker_server.id]
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  tags                        = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
  volume_tags                 = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
  root_block_device {
    delete_on_termination = var.delete_storage_on_term
    volume_type           = "gp2"
    volume_size           = var.docker_server_root_vol_size
  }
  ebs_block_device {
    delete_on_termination = var.delete_storage_on_term
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = var.docker_server_extra_vol_size
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_security_group" "k6s_docker_server" {
  name        = "k6s-docker-server"
  vpc_id      = var.vpc_id
  description = "docker_server security group (SSH, individual docker service ports)"

  tags = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }


  ingress {
    description = "k6s access"
    from_port   = var.k6s_listening_port
    to_port     = var.k6s_listening_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "test_harness_private" {
  zone_id = var.public_zone_id
  name    = var.test_harness_hostname
  type    = "A"
  ttl     = "300"
  records = [aws_instance.docker_server.private_ip]
}
