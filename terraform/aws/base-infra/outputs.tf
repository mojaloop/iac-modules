output "bastion_public_ip" {
  description = "Bastion Instance Hostname"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion Instance private ip"
  value       = aws_instance.bastion.private_ip
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

output "haproxy_server_fqdn" {
  description = "haproxy server Hostname"
  value       = var.create_haproxy_dns_record ? aws_route53_record.haproxy_server_private[0].fqdn : ""
}