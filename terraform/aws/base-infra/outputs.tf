output "bastion_public_ip" {
  description = "First bastion host public IP"
  value       = data.aws_instances.bastion_instances.public_ips[0]
}

output "bastion_private_ip" {
  description = "First bastion host public IP"
  value       = data.aws_instances.bastion_instances.private_ips[0]
}

output "bastion_public_ips" {
    description = "List of public IP addresses of bastion instances"
    value       = data.aws_instances.bastion_instances.public_ips
}

output "bastion_private_ips" {
    description = "List of private IP addresses of bastion instances"
    value       = data.aws_instances.bastion_instances.private_ips
}

output "ssh_private_key" {
  description = "Private key in PEM format"
  value       = tls_private_key.ec2_ssh_key.private_key_pem
  sensitive   = true
}

output "nat_public_ips" {
  description = "nat gateway public ips"
  value       = module.vpc.nat_public_ips
}

output "private_zone" {
  value = local.private_zone
}

output "public_int_zone" {
  value = local.public_int_zone
}

output "public_zone" {
  value = local.public_zone
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "netmaker_public_ip" {
  description = "Netmaker Instance Hostname"
  value       = var.enable_netmaker ? aws_instance.netmaker[0].public_ip : null
}

output "key_pair_name" {
  value = local.cluster_domain
}