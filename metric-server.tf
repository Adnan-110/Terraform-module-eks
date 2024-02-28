# resource "null_resource" "metric-server" {
#  depends_on = [null_resource.get-kube-config]
#  provisioner "local-exec" {
#    command = "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
#  }
# }