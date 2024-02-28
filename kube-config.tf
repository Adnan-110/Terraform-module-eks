resource "null_resource" "get-kube-config" {
  provisioner "local-exec" {
   // command = "aws eks update-kubeconfig  --name dev-eks-cluster"
      command = "echo fetching kubeconfig && echo run aws eks update-kubeconfig  --name dev-eks-cluster"
  }
}