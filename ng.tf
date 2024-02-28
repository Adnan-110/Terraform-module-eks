resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "tf-nodes-spot"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = var.PRIVATE_SUBNET_IDS
  capacity_type   = "SPOT"
  instance_types  = ["t3.xlarge"]

  scaling_config {
    desired_size = var.DESIRED_SIZE
    max_size     = var.MAX_SIZE
    min_size     = var.MIN_SIZE
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy-attach,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy-attach,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly-attach,
  ]
}
