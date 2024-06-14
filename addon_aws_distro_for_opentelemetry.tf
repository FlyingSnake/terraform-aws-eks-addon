resource "aws_iam_role" "aws_distro_for_opentelemetry" {
  count               = var.eks_addons["aws-distro-for-opentelemetry"] ? 1 : 0
  name                = "${var.name_prefix}eks-addon-adot-irsa-${local.oidc_id_substr}"
  tags                = merge({ Name = "${var.name_prefix}eks-addon-adot-irsa-${local.oidc_id_substr}" }, var.tags)
  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy", "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess", "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:opentelemetry-operator-system:opentelemetry-operator",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_eks_addon" "aws_distro_for_opentelemetry" {
  count                    = var.eks_addons["aws-distro-for-opentelemetry"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "adot"
  service_account_role_arn = aws_iam_role.aws_distro_for_opentelemetry[0].arn
  tags                     = merge({ Name = "${var.name_prefix}aws-distro-for-opentelemetry" }, var.tags)
  timeouts {
    create = "5m"
  }
}
