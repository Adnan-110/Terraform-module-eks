output "EKS" {
  value = aws_eks_cluster.eks
}

output "OIDC" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}