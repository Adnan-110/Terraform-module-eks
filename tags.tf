resource "aws_ec2_tag" "private-subnets" {
  count       = length(var.PRIVATE_SUBNET_IDS)
  resource_id = element(var.PRIVATE_SUBNET_IDS, count.index)
  key         = "kubernetes.io/cluster/${var.ENV}-eks-cluster"
  value       = "Owned"
}

resource "aws_ec2_tag" "private-subnets-lb" {
  count       = length(var.PRIVATE_SUBNET_IDS)
  resource_id = element(var.PRIVATE_SUBNET_IDS, count.index)
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "public-subnets" {
  count       = length(var.PUBLIC_SUBNET_IDS)
  resource_id = element(var.PUBLIC_SUBNET_IDS, count.index)
  key         = "kubernetes.io/cluster/${var.ENV}-eks-cluster"
  value       = "Owned"
}

resource "aws_ec2_tag" "public-subnets-lb" {
  count       = length(var.PUBLIC_SUBNET_IDS)
  resource_id = element(var.PUBLIC_SUBNET_IDS, count.index)
  key         = "kubernetes.io/role/elb"
  value       = "1"
}