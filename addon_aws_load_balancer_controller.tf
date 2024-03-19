locals {
  aws_loadbalancer_controller_trust_policy_json = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count              = var.helm_addons["aws-load-balancer-controller"] ? 1 : 0
  name               = "${var.name_prefix}eks-addon-load-balancer-controller-irsa-${local.oidc_id_substr}"
  assume_role_policy = local.aws_loadbalancer_controller_trust_policy_json
  tags               = merge({ Name = "${var.name_prefix}eks-addon-load-balancer-controller-irsa-${local.oidc_id_substr}" }, var.tags)
}

# The policy file was downloaded from the link below.
#   iam_policy_us-gov.json => https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy_us-gov.json
#   iam_policy.json => https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
resource "aws_iam_policy" "aws_load_balancer_controller" {
  count  = var.helm_addons["aws-load-balancer-controller"] ? 1 : 0
  name   = "${var.name_prefix}AWSLoadBalancerControllerIAMPolicy-${local.oidc_id_substr}"
  policy = contains(["us-east-2", "us-west-2"], data.aws_region.current.id) ? file("${path.module}/files/iam_policy_us-gov.json") : file("${path.module}/files/iam_policy.json")
  tags   = merge({ Name = "${var.name_prefix}AWSLoadBalancerControllerIAMPolicy-${local.oidc_id_substr}" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  count      = var.helm_addons["aws-load-balancer-controller"] ? 1 : 0
  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
  role       = aws_iam_role.aws_load_balancer_controller[0].name
}


resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  count = var.helm_addons["aws-load-balancer-controller"] ? 1 : 0
  metadata {
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller[0].arn
    }
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
  depends_on = [aws_iam_role.aws_load_balancer_controller]
}

resource "helm_release" "aws_load_balancer_controller" {
  count      = var.helm_addons["aws-load-balancer-controller"] ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.eks_cluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
