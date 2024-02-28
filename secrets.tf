resource "aws_iam_policy" "external-secrets-serviceaccount-policy" {
  count       = var.CREATE_EXTERNAL_SECRETS ? 1 : 0
  name        = "ExternalSecretsPolicy-${var.ENV}-eks-cluster"
  path        = "/"
  description = "ExternalSecretsPolicy-${var.ENV}-eks-cluster"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "kubernetes_service_account" "external-ingress-ingress-sa" {
  depends_on = [null_resource.get-kube-config]
  count = var.CREATE_EXTERNAL_SECRETS ? 1 : 0
  metadata {
    name      = "external-secrets-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external-secrets-oidc-role.arn
    }
  }
  automount_service_account_token = true
}

data "aws_iam_policy_document" "external-secrets-policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test = "StringEquals"
      variable = "${replace(
        aws_eks_cluster.eks.identity[0].oidc[0].issuer,
        "https://",
        "",
      )}:aud"
      values = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(
        aws_eks_cluster.eks.identity[0].oidc[0].issuer,
        "https://",
        "",
      )}"]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "external-secrets-oidc-role" {
  name               = "external-secrets-role-with-oidc"
  assume_role_policy = data.aws_iam_policy_document.external-secrets-policy_document.json
}

resource "aws_iam_role_policy_attachment" "external-secrets-role-attach" {
  count       = var.CREATE_EXTERNAL_SECRETS ? 1 : 0
  role       = aws_iam_role.external-secrets-oidc-role.name
  policy_arn = aws_iam_policy.external-secrets-serviceaccount-policy.*.arn[0]
}

resource "null_resource" "external-secrets-ingress-chart" {
  triggers = {
    a = timestamp()
  }
  depends_on = [null_resource.get-kube-config]
  count      = var.CREATE_EXTERNAL_SECRETS ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets -n kube-system --set serviceAccount.create=false --set serviceAccount.name=external-secrets-controller
sleep 30
kubectl apply -f ${path.module}/extras/external-store.yml
EOF
  }
}