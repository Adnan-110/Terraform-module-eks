resource "aws_eks_cluster" "eks" {
  name     = "${var.ENV}-eks-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.25"

  vpc_config {
    subnet_ids = var.PRIVATE_SUBNET_IDS
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}
