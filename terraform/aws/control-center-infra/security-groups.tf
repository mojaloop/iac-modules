resource "aws_security_group" "gitlab_server" {
  name        = "gitlab_server"
  vpc_id      = module.base_infra.vpc_id
  description = "GitLab security group (SSH, HTTP/S inbound access is allowed)"

  tags = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = concat([var.vpc_cidr], local.nat_gatewway_cidr_blocks)
    description = "GitLab Container Registry"
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

resource "aws_security_group" "docker_server" {
  name        = "docker_server"
  vpc_id      = module.base_infra.vpc_id
  description = "docker_server security group (SSH, individual docker service ports)"

  tags = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }


  ingress {
    description = "nexus admin access"
    from_port   = var.nexus_admin_listening_port
    to_port     = var.nexus_admin_listening_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "nexus docker repo http access"
    from_port   = var.nexus_docker_repo_listening_port
    to_port     = var.nexus_docker_repo_listening_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "minio access"
    from_port   = var.minio_listening_port
    to_port     = var.minio_listening_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "minio ui access"
    from_port   = var.minio_ui_port
    to_port     = var.minio_ui_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "vault access"
    from_port   = var.vault_listening_port
    to_port     = var.vault_listening_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "dex access"
    from_port   = var.dex_listening_port
    to_port     = var.dex_metrics_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "wireguard access"
    from_port   = 51820
    to_port     = 51825
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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
