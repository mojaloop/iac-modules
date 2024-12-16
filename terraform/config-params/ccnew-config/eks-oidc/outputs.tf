output "eks_identity_provider_status" {
  value     = aws_eks_identity_provider_config.eks_cluster.status
}

output "eks_identity_provider_id" {
  value     = aws_eks_identity_provider_config.eks_cluster.id
}